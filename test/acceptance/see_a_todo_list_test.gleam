import gleeunit
import gleeunit/should
import gleam/dict
import gleam/option
import gleam/list
import gleam/string
import gleam/regex
import wisp/testing
import app/router
import wisp.{type Response}
import domain.{type TodoList}

pub fn main() {
  gleeunit.main()
}

pub fn list_owners_ca_see_their_lists_test() {
  let user = "frank"
  let list_name = "shopping"
  let food_to_buy = ["carrots", "apples", "milk"]

  let assert Ok(list) = get_todo_list(user, list_name, food_to_buy)

  should.equal(list.name.value, list_name)

  list.items
  |> list.map(fn(item) { item.description })
  |> should.equal(food_to_buy)
}

fn get_todo_list(
  user: String,
  list_name: String,
  food_to_buy: List(String),
) -> Result(domain.TodoList, String) {
  let path = string.join(["todo", user, list_name], with: "/")

  let request = testing.get(path, [])
  let todo_items =
    list.map(food_to_buy, fn(description) {
      domain.TodoItem(description: description)
    })
  let todo_list =
    domain.TodoList(name: domain.ListName(value: list_name), items: todo_items)
  let store = dict.from_list([#(domain.User(value: user), [todo_list])])

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
      domain.TodoItem(description: description)
    })
  }

  let list_name = domain.ListName(value: list_name)
  domain.TodoList(name: list_name, items: todo_items)
}

fn error(_response: Response) -> String {
  "Failed"
}
