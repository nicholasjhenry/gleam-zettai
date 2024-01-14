import wisp.{type Request, type Response}
import gleam/string
import gleam/dict.{type Dict}
import gleam/list
import gleam/result
import gleam/string_builder
import app/web
import domain.{type ListName, type TodoItem, type TodoList, type User}

type HtmlPage {
  HtmlPage(raw: String)
}

type Store =
  Dict(User, List(TodoList))

pub fn handle_request(req: Request, store: Store) -> Response {
  case wisp.path_segments(req) {
    ["todo", user, list] ->
      show_list(store, req, #(
        domain.User(value: user),
        domain.ListName(value: list),
      ))

    _ -> wisp.not_found()
  }
}

fn show_list(store: Store, req: Request, list_id: #(User, ListName)) -> Response {
  let #(user, _list_name) = list_id

  let response =
    store
    |> fetch_list_content(list_id)
    |> render_html
    |> create_response

  use _req <- web.middleware(req)
  response
}

fn fetch_list_content(store: Store, list_id: #(User, ListName)) -> TodoList {
  let #(user, list_name) = list_id

  let lists_result = dict.get(store, user)

  let user_list_result =
    result.map(lists_result, fn(lists) {
      list.filter(lists, fn(list) { list.name == list_name })
    })

  case user_list_result {
    Ok([user_list]) -> user_list
    Ok(_) -> panic as "list unknown"
    Error(Nil) -> panic as "list unknown"
  }
}

fn render_html(list: TodoList) -> HtmlPage {
  let html_items = {
    case render_items(list.items) {
      Ok(html) -> html
      Error(Nil) -> "No items in this list"
    }
  }

  let raw =
    "<html>"
    |> string.append("<body>")
    |> string.append("<h1>Zettai</h1>")
    |> string.append("<h2>")
    |> string.append(list.name.value)
    |> string.append("</h2>")
    |> string.append("<table>")
    |> string.append(html_items)
    |> string.append("</table>")
    |> string.append("</body>")
    |> string.append("</html>")

  HtmlPage(raw: raw)
}

fn render_items(items: List(TodoItem)) {
  items
  |> list.map(fn(item) {
    ""
    |> string.append("<tr><td>")
    |> string.append(item.description)
    |> string.append("</td></tr>")
  })
  |> list.reduce(fn(html, snippet) { string.append(html, snippet) })
}

fn create_response(html: HtmlPage) -> Response {
  html.raw
  |> string_builder.from_string()
  |> wisp.html_response(200)
}
