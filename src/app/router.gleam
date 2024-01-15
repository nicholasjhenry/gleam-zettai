import wisp.{type Request, type Response}
import gleam/string
import gleam/list
import gleam/string_builder
import app/web
import app/domain.{type ListName, type TodoItem, type TodoList, type User}
import app/persistence.{type Store}
import app/hub

type HtmlPage {
  HtmlPage(raw: String)
}

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
  let response = case hub.fetch_list_content(store, list_id) {
    Ok(todo_list) ->
      todo_list
      |> render_html
      |> create_success_response
    Error(message) -> create_error_response(message)
  }

  use _req <- web.middleware(req)
  response
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

fn create_success_response(html: HtmlPage) -> Response {
  html.raw
  |> string_builder.from_string()
  |> wisp.html_response(200)
}

fn create_error_response(msg: String) -> Response {
  msg
  |> string_builder.from_string()
  |> wisp.html_response(500)
}
