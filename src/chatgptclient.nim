import os
import json

import pyopenai
import owlkettle

import chatgptclientpkg/preferences
import chatgptclientpkg/funcs


viewable App:
  openai: OpenAiClient
  messages: seq[JsonNode]
  systemPrompt: string = "You are a helpful assistant."
  model: string = "gpt-3.5-turbo"
  input: string
  entrySensitivity: bool = true

var thread: Thread[AppState]

proc threadProc(app: AppState) {.thread.} =
  try:
    let resp = app.openai.createChatCompletion(
       model = app.model,
       messages = app.messages
    )
    app.messages.add(
      resp["choices"][0]["message"]
    )
  except InvalidApiKey:
    errorNotification("Invalid API Key")
  except NotFound:
    errorNotification("Invalid Model")
  except InvalidParameters:
    errorNotification("Invalid parameters")
  except OSError:
    errorNotification("Connection failure")
  except Defect:
    errorNotification("Unknown error")

  app.entrySensitivity = true
  app.redrawFromThread()

method view(app: AppState): Widget =
  result = gui:
    Window:
      title = "Chat"
      defaultSize = (600, 400)

      proc close() =
        quit(QuitSuccess)

      HeaderBar {.addTitlebar.}:
        MenuButton {.addRight.}:
          icon = "open-menu-symbolic"

          PopoverMenu:
            Box:
              orient = OrientY
              margin = 4
              spacing = 3


              ModelButton:
                text = "Preferences"
                proc clicked() =
                  let (_, state) = app.open(
                    gui(
                      PreferencesDialog(
                        apiKey = app.openai.apiKey,
                        apiBase = app.openai.apiBase,
                        model = app.model,
                        systemPrompt = app.systemPrompt
                      )
                    )
                  )
                  let dialog = PreferencesDialogState(state)
                  app.openai.apiKey = dialog.apiKey
                  app.openai.apiBase = dialog.apiBAse
                  app.model = dialog.model
                  app.systemPrompt = dialog.systemPrompt
                  app.messages = @[]
                  app.messages.add(
                    %*{
                      "role": "system",
                      "content": dialog.systemPrompt
                    }
                  )
              ModelButton:
                text = "About"
                proc clicked() =
                  discard app.open: gui:
                    AboutDialog:
                      programName = "ChatGPT Client"
                      logo = "chat-symbolic"
                      version = "0.2.0"
                      credits = @{
                        "Code": @[
                          "jaredmontoya",
                        ]
                      }
      
      Box:
        orient = OrientY
        margin = 12
        spacing = 6
        
        ScrolledWindow:
          ListBox:
            for message in app.messages:
              case message["role"].str
                of "user":
                  ListBoxRow {.addRow.}:
                    proc activate() =
                      app.writeClipboard(message["content"].str)

                    Label:
                      text = "You: "&message["content"].str
                      x_align = 0
                      wrap = true

                of "assistant":
                  ListBoxRow {.addRow.}:
                    proc activate() =
                      app.writeClipboard(message["content"].str)

                    Label:
                      text = "AI: "&message["content"].str
                      x_align = 0
                      wrap = true

        Box {.vAlign: AlignStart, expand: false.}:
          orient = OrientX
          spacing = 6

          Entry {.hAlign: AlignFill.}:
            placeholder = "Ask me anything..."
            sensitive = app.entrySensitivity
            text = app.input

            proc changed(text: string) =
              app.input = text

            proc activate() =
              app.messages.add(
                %*{
                  "role": "user",
                  "content": app.input
                }
              )
              app.entry_sensitivity = false
              app.input = ""
              createThread(thread, threadProc, app)

          Button {.hAlign: AlignStart, expand: false.}:
            icon = "user-trash-symbolic"
            style = [ButtonDestructive]

            proc clicked() =
              app.messages = @[]
              app.messages.add(
                %*{
                  "role": "system",
                  "content": app.systemPrompt
                }
              )

when isMainModule: 
  var openai = OpenAiClient(
    apiKey: getEnv("OPENAI_API_KEY")
  )

  var messages: seq[JsonNode]
  messages.add(
    %*{
      "role": "system",
      "content": "You are a helpful assistant."
    }
  )
  brew(
    "com.jaredmontoya.chatgptclient",
    gui(
      App(
        openai = openai,
        messages = messages
      )
    )
  )
