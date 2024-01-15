import app/domain.{type TodoList, TodoList}
import app/persistence.{type Store}

pub type GetTodoList =
  fn(Store, String, String) -> Result(TodoList, String)
