import std/[macros, genasts]


macro makeRpcConnection*(client, server: untyped): untyped =
  when defined(js):
    let client =
      if client.kind == nnkPrefix and client[0].strVal == "$/":
        genAst(client = client[1]):
          polyrpc/connections/web/clients/client
      else: client

    genAst(client):
      import client

  else:
    let server =
      if server.kind == nnkPrefix and server[0].strVal == "$/":
        genAst(server = server[1]):
          polyrpc/connections/web/servers/server
      else: server

    genAst(server):
      import server