include polyrpc/client
import karax/kajax except toJson, fromJson

makeRpcClientCb:
  ajaxPost(requestUrl.kstring, [], requestBody.kstring,
    proc(httpStatus: int, response: kstring) =
      case httpStatus
      of 200: callback($response)
      else: discard
  )