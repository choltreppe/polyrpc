import polyrpc/connections/http

makeRpcConnection(
  client = $/karaxRpc,
  server = $/prologueRpc
)


client:
  include karax/prelude

server:
  import prologue
  import prologue/middlewares/staticfile

  var app = newApp()
  initRpc app
  app.get("/test", redirectTo("test.html"))
  app.get("/test.js", redirectTo("test.js"))


server:

  proc foo(x: int, y: bool): float {.rpc("/foo1").} =
    if y: float(x) * 1.5
    else: 0.0

  proc foo(x: float): bool {.rpcA.} =
    x > 0

client:

  proc createDom: VNode =
    var done {.global.} = false
    if not done:

      foo(3, true, proc(res: float) =
        echo (res + 0.1)
      )

      foo(3, false, proc(res: float) =
        echo res
      )

      foo(1.5, proc(res: bool) =
        echo res
      )

    done = true
    buildHtml(tdiv())

  setRenderer createDom


server: run app