include polyrpc/client
import ajax

makeRpcClientCb:
  var xhr = new_xmlhttp_request()
  if xhr.is_nil: return
  
  proc onRecv(e:Event) =
    if xhr.readyState == rsDONE:
      if xhr.status == 200:
        callback($xhr.responseText)

  xhr.onreadystatechange = onRecv
  xhr.open("POST", requestUrl)
  xhr.send(requestBody.cstring)