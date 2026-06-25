switch("define", "ssl")
switch("threads", "on")
switch("app", "gui")
switch("mm", "arc")
switch("define", "release")
switch("define", "adwminor=2")
# begin Nimble config (version 2)
--noNimblePath
when withDir(thisDir(), system.fileExists("nimble.paths")):
  include "nimble.paths"
# end Nimble config
