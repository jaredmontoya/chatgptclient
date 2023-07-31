# Package

version       = "0.1.2"
author        = "jaredmontoya"
description   = "Native gui client for OpenAI chatgpt"
license       = "GPL-3.0-or-later"
srcDir        = "src"
bin           = @["chatgptclient"]


# Dependencies

requires "nim >= 1.6.12"
requires "nigui >= 0.2.6"
requires "pyopenai >= 0.1.1"
