import gleam/option
import gleam/list
import gleam/string
import gleam/regex
import wisp/testing
import wisp.{type Response}
import app/router
import app/domain.{type TodoList, TodoItem, TodoList}
import app/persistence.{type Store}

pub fn get_todo_list(
  store: Store,
  user: String,
  list_name: String,
) -> Result(TodoList, String) {
  let path = string.join(["todo", user, list_name], with: "/")
  let request = testing.get(path, [])

  let response = router.handle_request(request, store)

  case response.status {
    200 -> Ok(parse_response(response))
    _ -> Error(error(response))
  }
}

fn parse_response(response: Response) -> TodoList {
  let assert Ok(title_pattern) = regex.from_string("<h2>(.*?)</h2>")

  let body = testing.string_body(response)

  let assert [regex.Match(_match, [option.Some(list_name)])] =
    regex.scan(with: title_pattern, content: body)

  let assert Ok(item_pattern) = regex.from_string("<td>(.*?)?</td>")

  let todo_items = {
    item_pattern
    |> regex.scan(content: body)
    |> list.map(fn(match) {
      let assert regex.Match(_html, [option.Some(description)]) = match
      TodoItem(description: description)
    })
  }

  let list_name = domain.ListName(value: list_name)
  TodoList(name: list_name, items: todo_items)
}

fn error(_response: Response) -> String {
  "list_unknown"
}
