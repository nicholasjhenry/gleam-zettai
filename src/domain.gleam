pub type User {
  User(value: String)
}

pub type TodoList {
  TodoList(name: ListName, items: List(TodoItem))
}

pub type ListName {
  ListName(value: String)
}

pub type Headers =
  List(#(String, String))

pub type TodoItem {
  TodoItem(description: String)
}

pub type TodoStatus {
  Todo
  InProgress
  Done
  Blocked
}
