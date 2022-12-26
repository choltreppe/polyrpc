include polyrpc/server
import prologue

template initRpc*(app: Prologue): untyped =
  makeRpcServerHandler:
    app.post(requestUrl,
      proc(ctx {. inject .}: Context) {.async.} =
        {.cast(gcsafe).}:
          resp callProc(ctx.request.body)
    )