include polyrpc/client
import std/[dom, asyncjs]
import ajax

makeRpcClientReturn( when T is Future: T else: Future[T] ):
  return newPromise[T](proc(resolve: proc(response: T)) =
    var xhr = newXmlhttpRequest()
    if xhr.isNil: return
    
    proc onRecv(e:Event) =
      if xhr.readyState == rsDONE:
        if xhr.status == 200:
          resolve resultVal($xhr.responseText)

    xhr.onReadyStateChange = onRecv
    xhr.open("POST", requestUrl)
    xhr.send(requestBody.cstring)
  )