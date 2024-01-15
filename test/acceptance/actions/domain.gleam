import app/hub
import app/domain.{type TodoList, TodoList}
import app/persistence.{type Store}

pub fn get_todo_list(
  store: Store,
  user: String,
  list_name: String,
) -> Result(TodoList, String) {
  let user = domain.User(user)
  let list_name = domain.ListName(list_name)

  hub.fetch_list_content(store, #(user, list_name))
}
