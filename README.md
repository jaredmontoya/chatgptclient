# chatgptclient

![](https://img.shields.io/github/languages/top/jaredmontoya/chatgptclient?style=flat)
![](https://img.shields.io/github/languages/code-size/jaredmontoya/chatgptclient?style=flat)

Native gui client for OpenAI chatgpt

### **[Screenshots](.github/images)**:
![Alt text](.github/images/chat.png "chat")
![Alt text](.github/images/settings.png "settings")

# Installation
To install chatgptclient, you can simply run
```
nimble install chatgptclient
```
- Uninstall with `nimble uninstall chatgptclient`.
- nimble repo page: https://nimble.directory/pkg/chatgptclient

# Requisites

- [Nim](https://nim-lang.org)

# Caveats
- Note that if you are installing Gtk3+ via Homebrew on macOS running on Apple 
Silicon, you may need to provide the environment variable 
`DYLD_LIBRARY_PATH="/opt/homebrew/lib"`.