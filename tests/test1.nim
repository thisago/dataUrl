import std/unittest
import ./img2url

suite "img2url":
  test "Can say":
    const msg = "Hello from img2url test"
    check msg == say msg
