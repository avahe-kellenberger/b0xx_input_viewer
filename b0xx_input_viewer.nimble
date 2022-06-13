# Package

version       = "0.1.0"
author        = "Avahe Kellenberger"
description   = "A new awesome nimble package"
license       = "GPL-2.0-only"
srcDir        = "src"
bin           = @["b0xx_input_viewer"]


# Dependencies

requires "nim >= 1.6.6"

task runr, "Runs the program":
  exec "nim r -d:release src/b0xx_input_viewer.nim"

task daemon, "Runs the program as a daemon":
  exec "nim r -d:release -d:daemon src/b0xx_input_viewer.nim"
