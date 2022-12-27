include polyrpc/client
import std/[dom, asyncjs]
import ajax

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