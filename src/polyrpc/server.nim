include common


macro client*(_: untyped): untyped = discard
macro server*(body: untyped): untyped = body


template makeRpcServerHandler*(body: untyped): untyped =
  
  macro rpc*(requestUrl {.inject.}: static string, procedure: untyped): untyped =
    procedure.expectKind({nnkProcDef, nnkFuncDef})

    registerRpcUrl requestUrl

    let requestBody = genSym(nskParam, "requestBody")

    var procCall = newCall(macros.name(procedure))
    let paramAssign =
      if len(macros.params(procedure)) <= 1: newStmtList()
      else:

        var paramsType = macros.newNimNode(nnkTupleConstr)
        var paramAssign = macros.newNimNode(nnkVarTuple)

        var j: int
        for p in macros.params(procedure)[1 .. ^1]:
          for _ in 0 ..< p.len-2:
            paramsType.add(p[^2])
            let param = ident("param" & $j)
            paramAssign.add(param)
            procCall.add(param)
            j += 1

        macros.newTree(nnkLetSection,
          macros.add(paramAssign,
            newEmptyNode(),
            deserializeCall(requestBody, paramsType)
          )
        )

    let addHandler = genAst(requestUrl, paramAssign, serialized = serializeCall(procCall), requestBody):
      template callProc(requestBody: string): untyped {.inject.} =
        paramAssign
        serialized
      body

    macros.newStmtList(procedure, addHandler)