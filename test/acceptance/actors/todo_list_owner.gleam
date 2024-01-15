import gleeunit/should
import gleam/list
import app/domain.{type TodoList, ListName, TodoItem, TodoList}
import app/persistence.{type Store}
import acceptance/actions.{type GetTodoList}

pub type TodoListOwner {
  TodoListOwner(name: String)
}

pub fn can_see_the_list(
  owner: TodoListOwner,
  store: Store,
  list_name: String,
  items: List(String),
  action: GetTodoList,
) {
  let expected_list = create_list(list_name, items)
  let assert Ok(list) = action(store, owner.name, list_name)

  should.equal(list, expected_list)
}

pub fn cannot_see_the_list(
  owner: TodoListOwner,
  store: Store,
  list_name: String,
  _items: List(String),
  action: GetTodoList,
) {
  let result = action(store, owner.name, list_name)

  should.equal(result, Error("list_unknown"))
}

fn create_list(list_name, item_descriptions) {
  let items =
    list.map(item_descriptions, fn(description) { TodoItem(description) })
  TodoList(ListName(list_name), items)
}
