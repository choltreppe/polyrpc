import std/macros
import jsony
import polyrpc/connections/http

makeRpcConnection(
  client = $/ajaxFutureRpc,
  server = $/mummyRpc
)
setRpcAnnonymousUrl "/a"

static:
  serializeCall =
    proc(val: NimNode): NimNode =
      quote do: `val`.toJson

  deserializeCall =
    proc(str, T: NimNode): NimNode =
      quote do: `str`.fromJson(`T`)


client:
  import std/asyncjs

server:
  import mummy, mummy/routers

  var router: Router
  initRpc router

  router.get("/test") do (request: Request):
    request.respond(200, @[("Content-Type", "text/html")], readFile("test.html"))

  router.get("/test.js") do (request: Request):
    request.respond(200, @[("Content-Type", "application/javascript")], readFile("test.js"))


server:
  func foo(a: int): int {.rpca.} = 3*a - 1


client:
  proc ba {.async.} =
    echo await foo(4)

  discard ba()


server:
  let server = newServer(router)
  echo "Serving on http://localhost:8080"
  server.serve(Port(8080))