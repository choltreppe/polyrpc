# polyrpc
A system for generating remote-procedure-calls for any pair of server and client.

## Example
have a lookn at `tests/` to get a general idea of the system.

## predefined connections

To establish a connection you can use the predefined ones.<br>
For example to connect karax client with prologue server:
```nim
import polyrpc/connections/http

makeRpcConnection(
  client = $/karaxRpc,
  server = $/prologueRpc
)
```
The `polyrpc/connections/http` provides the `makeRpcConnection` macro, to generate a http connection. <br>
`client` is the clients rpc connections module, and `server` the server one.<br>
for convinence `$/` can be used as a shortcut for predefined ones.<br>
So this is the same without `$/`:
```nim
makeRpcConnection(
  client = polyrpc/connections/http/clients/karaxRpc,
  server = polyrpc/connections/http/servers/prologueRpc
)
```
And that expands to:
```nim
when defined(js):
  import polyrpc/connections/http/clients/karaxRpc
else:
  import polyrpc/connections/http/servers/prologueRpc
```

## using the connection
first of all you need to seperate your code into server and client parts.<br>
to do so use the `server` and `client` macros to define sections like so:
```nim
server:
  # do some stuff on server

client:
  # do some stuff on client
  
# do some stuff on both

server: # do some more on server
```
or use them as pragma on single procs:
```nim
proc foo {.server.}
```
now if you want to make a server proc rpc callable just add the `rpc` pragma with the url it schould use,<br>
or the `rpca` pragma for auto generated urls
```nim
server:
  proc add(a,b: int): int {.rpc("/add").} = a + b
  proc isNeg(x: int): bool {.rpca.} = x < 0
```
You can change the base url for `rpca` (default is "/rpc")
```nim
setRpcAnnonymousUrl "/foo"
```

## custom connections

### server
To define a custom cennection import `polyrpc/server` and use the `makeRpcServerHandler` template.<br>
Here is how `prologueRpc`s `initRpc` is defined:
```nim
template initRpc*(app: Prologue): untyped =
  makeRpcServerHandler:
    app.post(requestUrl,
      proc(ctx {. inject .}: Context) {.async.} =
        {.cast(gcsafe).}:
          resp callProc(ctx.request.body)
    )
```
inside the definition you can use:<br>
`requestUrl`<br>
`callProc` to call the proc (it expects a string as input and returns a string, it does the rest for you)

### client
To define a custom cennection import `polyrpc/client` and use the `makeRpcClientCb` or the `makeRpcClientReturn` template.

Use `makeRpcClientCb` for a callback pattern.<br>
With the callback pattern:
```nim
proc foo(x: int): bool {.rpca.}
```
becomes:
```nim
proc foo(x: int, cb: proc(r: bool))
```
Here is how `karaxRpc` is defined using `makeRpcClientCb`:
```nim
makeRpcClientCb:
  ajaxPost(requestUrl.kstring, [], requestBody.kstring,
    proc(httpStatus: int, response: kstring) =
      case httpStatus
      of 200: callback($response)
      else: discard
  )
```
Inside the defenition there are following things defined:<br>
`requestUrl`: the url which the rpc should use<br>
`requestBody`: the body string that needs to be send<br>
`callback`: the callback that needs to be called with the response string

Use `makeRpcClientReturn` for generating functions that return the result. (just like the original proc, but with potentialy modified return type)<br>
Here is how `ajaxFutureRpc` is defined using `makeRpcClientCb`:
```nim
makeRpcClientReturn( when T is Future: T else: Future[T] ):
  return newPromise[T](proc(resolve: proc(response: T)) =
    var xhr = new_xmlhttp_request()
    if xhr.is_nil: return
    
    proc onRecv(e:Event) =
      if xhr.readyState == rsDONE:
        if xhr.status == 200:
          resolve resultVal($xhr.responseText)

    xhr.onreadystatechange = onRecv
    xhr.open("POST", requestUrl)
    xhr.send(requestBody.cstring)
  )
```
The first parameter defines what the return type should be,<br>
based on the original return type `T`<br>
The second parameter defines the proc body. There are following things defined inside:<br>
`requestUrl`: the url which the rpc should use<br>
`requestBody`: the body string that needs to be send<br>
`resultVal`: proc to turn result string into actual type

## change serializing / deserializing procs

for example to use `jsony`:
```nim
static:
  serializeCall =
    proc(val: NimNode): NimNode =
      quote do: `val`.toJson

  deserializeCall =
    proc(str, T: NimNode): NimNode =
      quote do: `str`.fromJson(`T`)
```

This will probably be simplyfied with macros in the future.

# Contribution
Issues and PRs welcome
