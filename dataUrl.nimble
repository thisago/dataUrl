# Package

version       = "0.1.0"
author        = "Thiago Ferreira"
description   = "Converts locally or remote resources in data url content"
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 1.0.0"

# CLI tool
requires "cligen"

bin = @["dataUrl"]
binDir = "build"

task build_release, "Builds the release version":
  exec "nimble -d:release build"
task build_danger, "Builds the danger version":
  exec "nimble -d:danger build"
task gen_docs, "Generates the documentation":
  exec "nim doc --project --out:docs src/img2url.nim"
