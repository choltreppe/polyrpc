import std/macros
import jsony
import polyrpc/connections/http

makeRpcConnection(
  client = $/ajaxFutureRpc,
  server = $/prologueRpc
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
  import prologue
  import prologue/middlewares/staticfile

  var app = newApp()
  initRpc app
  app.get("/test", redirectTo("test.html"))
  app.get("/test.js", redirectTo("test.js"))


server:
  func foo(a: int): int {.rpca.} = 3*a - 1


client:
  proc ba {.async.} =
    echo await foo(4)

  discard ba()


server: run app