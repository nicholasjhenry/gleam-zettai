import wisp.{type Request, type Response}
import gleam/string_builder
import app/web

pub fn handle_request(req: Request) -> Response {
  let html_page =
    "
    <html>
        <body>
            <h1 style=\"text-align:center; font-size:3em;\" >
                Hello Functional World!
            </h1>
        </body>
    </html>
  "
  use _req <- web.middleware(req)
  let body = string_builder.from_string(html_page)
  wisp.html_response(body, 200)
}
