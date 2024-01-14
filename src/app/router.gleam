import wisp.{type Request, type Response}
import gleam/string
import gleam/string_builder
import app/web

pub fn handle_request(req: Request) -> Response {
  case wisp.path_segments(req) {
    ["todo", user, list] -> show_list(req, user, list)

    _ -> wisp.not_found()
  }
}

fn show_list(req: Request, user: String, list: String) -> Response {
  let html_page =
    "<html>"
    |> string.append("<body>")
    |> string.append("<h1>Zettai</h1>")
    |> string.append("<p>Here is the list <b>")
    |> string.append(list)
    |> string.append("</b> of user <b>")
    |> string.append(user)
    |> string.append("</b></body>")
    |> string.append("</html>")

  use _req <- web.middleware(req)
  let body = string_builder.from_string(html_page)
  wisp.html_response(body, 200)
}
