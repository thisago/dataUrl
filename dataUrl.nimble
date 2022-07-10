# Package

version       = "1.3.1"
author        = "Thiago Navarro"
description   = "Easily create data urls! CLI included"
license       = "MIT"
srcDir        = "src"

# Dependencies

requires "nim >= 1.0.0"

# CLI tool
requires "cligen"

bin = @["dataUrl"]
binDir = "build"
installExt = @["nim"]

task build_release, "Builds the release version":
  exec "nimble -d:release build"
task build_danger, "Builds the danger version":
  exec "nimble -d:danger build"
task gen_docs, "Generates the documentation":
  exec "nim doc --project --out:docs src/dataUrl.nim"
