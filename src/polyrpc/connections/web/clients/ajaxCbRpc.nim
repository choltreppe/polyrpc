include polyrpc/client
import ajax

makeRpcClientCb:
  var xhr = newXmlhttpRequest()
  if xhr.isNil: return
  
  proc onRecv(e:Event) =
    if xhr.readyState == rsDONE:
      if xhr.status == 200:
        callback($xhr.responseText)

  xhr.onReadyStateChange = onRecv
  xhr.open("POST", requestUrl)
  xhr.send(requestBody.cstring)