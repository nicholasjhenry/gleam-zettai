import gleeunit
import gleeunit/should
import gleam/string
import wisp/testing
import app/router
import wisp.{type Response}

pub fn main() {
  gleeunit.main()
}

pub fn list_owners_ca_see_their_lists_test() {
  let user = "frank"
  let list_name = "shopping"
  let food_to_buy = ["carrots", "apples", "milk"]

  let body = get_todo_list(user, list_name, food_to_buy)

  let expected_body = "Here is the list <b>shopping</b> of user <b>frank</b>"
  should.be_true(string.contains(does: body, contain: expected_body))
}

fn get_todo_list(
  user: String,
  list_name: String,
  _food_to_buy: List(String),
) -> String {
  let path = string.join(["todo", user, list_name], with: "/")
  let request = testing.get(path, [])
  let response = router.handle_request(request)

  case response.status {
    200 -> parse_response(response)
    _ -> error(response)
  }
}

fn parse_response(response: Response) -> String {
  testing.string_body(response)
}

fn error(_response: Response) -> String {
  "Failed"
}
