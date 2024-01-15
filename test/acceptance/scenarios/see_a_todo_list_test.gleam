import gleeunit
import gleam/dict
import gleam/iterator
import gleam/list
import app/domain
import acceptance/actors/todo_list_owner.{type TodoListOwner, TodoListOwner}
import acceptance/actions/http as http_actions
import acceptance/actions/domain as domain_actions

pub fn main() {
  gleeunit.main()
}

fn actions() {
  [http_actions.get_todo_list, domain_actions.get_todo_list]
}

pub fn list_owners_can_see_their_lists_test() {
  let frank = TodoListOwner("frank")
  let list_name = "shopping"
  let food_to_buy = ["carrots", "apples", "milk"]
  let store = build_store(frank, list_name, food_to_buy)

  step(actions(), todo_list_owner.can_see_the_list(
    frank,
    store,
    list_name,
    food_to_buy,
    _,
  ))
}

pub fn only_owners_can_see_their_lists_test() {
  let frank = TodoListOwner("frank")
  let list_name = "shopping"
  let items = list.new()
  let store = build_store(frank, list_name, items)

  let bob = TodoListOwner("bob")

  step(actions(), todo_list_owner.cannot_see_the_list(
    bob,
    store,
    list_name,
    items,
    _,
  ))
}

fn build_store(owner: TodoListOwner, list_name, item_names) {
  let todo_items =
    list.map(item_names, fn(description) {
      domain.TodoItem(description: description)
    })
  let todo_list =
    domain.TodoList(name: domain.ListName(value: list_name), items: todo_items)

  dict.from_list([#(domain.User(value: owner.name), [todo_list])])
}

fn step(actions, func) {
  actions
  |> iterator.from_list
  |> iterator.each(func)
}
