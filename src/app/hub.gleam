import gleam/dict
import gleam/list
import gleam/result
import app/domain.{type ListName, type TodoList, type User}
import app/persistence.{type Store}

pub fn fetch_list_content(
  store: Store,
  list_id: #(User, ListName),
) -> Result(TodoList, String) {
  let #(user, list_name) = list_id
  let lists_result = dict.get(store, user)

  let user_list_result =
    result.map(lists_result, fn(lists) {
      list.filter(lists, fn(list) { list.name == list_name })
    })

  case user_list_result {
    Ok([user_list]) -> Ok(user_list)
    _ -> Error("list_unknown")
  }
}
