import chatgptclientpkg/gui

proc ctrlChandler() {.noconv.} =
    gui.stop()

setControlCHook(ctrlChandler)

when isMainModule:
  gui.start()
