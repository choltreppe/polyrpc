# Package

version       = "0.2.2"
author        = "Joel Lienhard"
description   = "A lib for generating rpc interface for any client server pair"
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 1.6.10"
requires "jsony >= 1.1.5"


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


task testMummy, "test Mummy":

  withDir "tests/ajaxFutureMummy":
    exec "nim c --threads:on test.nim"
    exec "nim js test.nim"
    exec "./test"