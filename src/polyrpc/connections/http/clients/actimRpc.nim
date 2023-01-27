include polyrpc/client
import actim/ajaxim

makeRpcClientCb:
  ajaxPost(requestUrl, requestBody) do (status: Natural, response: string):
    callback(response)