import gleam/erlang/process
import gleam/dict
import gleam/list
import mist
import wisp
import app/router
import app/domain

pub fn main() {
  wisp.configure_logger()

  let secret_key_base = wisp.random_string(64)

  let store = build_store()

  let handler = router.handle_request(_, store)

  let assert Ok(_) =
    wisp.mist_handler(handler, secret_key_base)
    |> mist.new
    |> mist.port(8000)
    |> mist.start_http

  process.sleep_forever()
}

fn build_store() {
  let todo_items =
    list.map(["one", "two", "three"], fn(description) {
      domain.TodoItem(description: description)
    })
  let todo_list =
    domain.TodoList(name: domain.ListName(value: "foo"), items: todo_items)
  dict.from_list([#(domain.User(value: "nicholas"), [todo_list])])
}
