# Package

version       = "0.2.0"
author        = "jaredmontoya"
description   = "Native gui client for OpenAI chatgpt"
license       = "GPL-3.0-or-later"
srcDir        = "src"
bin           = @["chatgptclient"]


# Dependencies

requires "nim ^= 2.0.0"
requires "owlkettle ^= 3.0.0"
requires "pyopenai ^= 0.2.0"
