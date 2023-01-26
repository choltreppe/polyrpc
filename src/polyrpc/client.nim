import std/[macros, genasts, sequtils, strutils]
import jsony

include common


template client*(body: untyped): untyped = body

macro server*(body: untyped): untyped =
  result = newStmtList()
  for elem in
    case body.kind:
      of nnkStmtList:            body.toSeq
      of nnkProcDef, nnkFuncDef: @[body]
      else:                      @[]
  :
    if elem.kind == nnkProcDef or elem.kind == nnkFuncDef:
      for p in elem.pragma:
        if p.kind in {nnkCall, nnkCommand} and cmpIgnoreStyle(p[0].strVal, "rpc" ) == 0 or
           p.kind == nnkIdent              and cmpIgnoreStyle(p.strVal,    "rpca") == 0:
              result.add(elem)
              break


template makeRpcClientReturn*(returnType, body: untyped): untyped =

  macro rpc*(requestUrl {.inject.}: static string, procedure: untyped): untyped =
    procedure.expectKind({nnkProcDef, nnkFuncDef})

    registerRpcUrl requestUrl

    var paramTuple = newNimNode(nnkTupleConstr)
    for p in procedure.params[1 .. ^1]:
      for p_ident in p[0 ..< ^2]:
        paramTuple.add(p_ident)

    let
      requestBody {.inject.} = genAst(paramTuple): toJson(paramTuple)
      resultVal   {.inject.} = genSym(nskFunc, "resultVal")

    var params = procedure.params
    let T {.inject.} = params[0]
    params[0] = genAst(T): returnType

    nnkProcDef.newTree(
        procedure[0],
        newEmptyNode(), newEmptyNode(),
        params,
        newEmptyNode(), newEmptyNode(),
        genAst(requestUrl, requestBody, resultVal, T) do:
          func resultVal(response: string): T {.inject.} =
            fromJson(response, T)
          body
      )


template makeRpcClientCb*(body: untyped): untyped =

  macro rpc*(requestUrl {.inject.}: static string, procedure: untyped): untyped =
    procedure.expectKind({nnkProcDef, nnkFuncDef})

    registerRpcUrl requestUrl

    var paramTuple = newNimNode(nnkTupleConstr)
    for p in procedure.params[1 .. ^1]:
      for p_ident in p[0 ..< ^2]:
        paramTuple.add(p_ident)

    let
      requestBody {.inject.} = genAst(paramTuple): toJson(paramTuple)
      cbProc                 = genSym(nskParam, "cb")
      callback    {.inject.} = genSym(nskTemplate, "callback")

    var params = procedure.params
    let resultType = params[0]
    params[0] = newEmptyNode()
    params.add nnkIdentDefs.newTree(
      cbProc,
      nnkProcTy.newTree(
        nnkFormalParams.newTree(
          newEmptyNode(),
          nnkIdentDefs.newTree(ident"r", resultType, newEmptyNode())),
          newEmptyNode()
        ),
      newEmptyNode()
    )

    nnkProcDef.newTree(
        procedure[0],
        newEmptyNode(), newEmptyNode(),
        params,
        newEmptyNode(), newEmptyNode(),
        genAst(requestUrl, requestBody, resultType, cbProc, callback) do:
          template callback(response: string) {.inject.} =
            cbProc(fromJson(response, resultType))
          body
      )