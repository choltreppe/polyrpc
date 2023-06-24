include polyrpc/server
import mummy, mummy/routers

template initRpc*(router: Router): untyped =
  makeRpcServerHandler:
    router.post(requestUrl,
      proc(request: Request) =
        request.respond(200, body = callProc(request.body))
    )