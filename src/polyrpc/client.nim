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
      requestBody {.inject.} = serializeCall(paramTuple)
      resultVal   {.inject.} = genSym(nskFunc, "resultVal")

    var params = procedure.params
    let T {.inject.} = params[0]
    params[0] = genAst(T): returnType

    let
      response  = genSym(nskParam, "response")
      resultVal = genSym(nskProc,  "resultVal")

    nnkProcDef.newTree(
      procedure[0],
      newEmptyNode(), newEmptyNode(),
      params,
      newEmptyNode(), newEmptyNode(),
      newStmtList(
        nnkFuncDef.newTree(
          resultVal,
          newEmptyNode(), newEmptyNode(),
          nnkFormalParams.newTree(
            T,
            nnkIdentDefs.newTree(response, ident"string", newEmptyNode())
          ),
          newEmptyNode(), newEmptyNode(),
          deserializeCall(response, T)
        ),
        genAst(requestUrl, requestBody, resultVal, T) do: body
      )
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
      requestBody {.inject.} = serializeCall(paramTuple)
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

    let
      response = genSym(nskParam, "response")
      callback = genSym(nskProc,  "callback")

    result = nnkProcDef.newTree(
      procedure[0],
      newEmptyNode(), newEmptyNode(),
      params,
      newEmptyNode(), newEmptyNode(),
      newStmtList(
        nnkTemplateDef.newTree(
          callback,
          newEmptyNode(), newEmptyNode(),
          nnkFormalParams.newTree(
            newEmptyNode(),
            nnkIdentDefs.newTree(response, ident"string", newEmptyNode())
          ),
          newEmptyNode(), newEmptyNode(),
          newCall(cbProc, deserializeCall(response, resultType))
        ),
        genAst(requestUrl, requestBody, callback) do: body
      )
    )
    debugEcho result.repr