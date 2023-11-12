# Package

version       = "0.2.0"
author        = "jaredmontoya"
description   = "Native gui client for OpenAI chatgpt"
license       = "GPL-3.0-or-later"
srcDir        = "src"
bin           = @["chatgptclient"]


# Dependencies

requires "nim ^= 2.0.0"
requires "owlkettle#58c512e5729a44dcbe9fb3ea0be0aa37adc1b7f8"
requires "pyopenai ^= 0.2.0"
