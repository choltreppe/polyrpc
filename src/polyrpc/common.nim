import std/[macros, genasts, sequtils, strutils, sets, base64]
import unibs

export unibs, base64


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