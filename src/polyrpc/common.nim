import std/[macros, genasts, sequtils, strutils, sets, base64]
import unibs

export base64, unibs


var
  serializeCall* {.compiletime.} =
    proc(val: NimNode): NimNode =
      quote do: base64.encode(unibs.serialize(`val`))

  deserializeCall* {.compiletime.} =
    proc(str, T: NimNode): NimNode =
      quote do: unibs.deserialize(base64.decode(`str`), `T`)

#[template setSerializeCall*(body: untyped) =
  static:
    serializeCall =
      proc(val {.inject.}: NimNode): NimNode =
        genAst(val): body

template setDeserializeCall*(body: untyped) =
  static:
    serializeCall =
      proc(str {.inject.}, T {.inject.}: NimNode): NimNode =
        genAst(str, T): body]#


var
  usedRequestUrls  {.compiletime.}: HashSet[string]
  annonymousPrefix {.compiletime.} = "/rpc"
  nextAnnonymousId {.compiletime.} = 0


macro setRpcAnnonymousUrl*(url: static string) =
  annonymousPrefix = url

proc registerRpcUrl(requestUrl: string) {.compiletime.} =
  when not defined(release):
    assert requestUrl notin usedRequestUrls
    usedRequestUrls.incl requestUrl

macro rpca*(procedure: untyped): untyped =
  var url = ""
  while (url = annonymousPrefix & $nextAnnonymousId; url) in usedRequestUrls:
    inc nextAnnonymousId

  newCall(ident"rpc", newLit(url), procedure)