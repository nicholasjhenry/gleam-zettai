import gleam/dict.{type Dict}
import app/domain.{type TodoList, type User}

pub type Store =
  Dict(User, List(TodoList))
