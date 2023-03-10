# Package

version       = "0.1.0"
author        = "Joel Lienhard"
description   = "A lib for generating rpc interface for any client server pair"
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 1.6.10"
requires "unibs >= 0.1.1"


task testKaraxPrologue, "test connection between karax and prologue":

  withDir "tests/karaxPrologue":
    exec "nim c test.nim"
    exec "nim js test.nim"
    exec "./test"


task testAjaxFuture, "test ajax Future":

  withDir "tests/ajaxFuturePrologue":
    exec "nim c test.nim"
    exec "nim js test.nim"
    exec "./test"
