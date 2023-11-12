import os
import json

import pyopenai
import owlkettle
import owlkettle/adw


viewable App:
  openai: OpenAiClient
  messages: seq[JsonNode]
  systemPrompt: string = "You are a helpful assistant."
  model: string = "gpt-3.5-turbo"
  input: string
  entrySensitivity: bool = true

var thread: Thread[AppState]

proc errorNotification(text: string) =
  sendNotification(
    "my-notification",
    title = "Error",
    body = text,
    icon = "preferences-system-notifications",
    category = "im.recieved",
    priority = NotificationHigh
  )

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
          style = [ButtonFlat]

          PopoverMenu:
            Box:
              orient = OrientY
              margin = 4
              spacing = 3


              ModelButton:
                text = "Preferences"
                proc clicked() =
                  discard app.open: gui:
                    Window:
                      title = "Preferences"
                      defaultSize = (500, 0)
                      HeaderBar {.addTitlebar.}

                      Box:
                        orient = OrientY
                        margin = 12
                        spacing = 12

                        PreferencesGroup {.expand: false.}:
                          title = "Settings"
            

                          ActionRow:
                            title = "API Key"
                            subtitle = "An API Key to use for requests"
                            Entry {.addSuffix.}:
                              text = app.openai.apiKey
                              placeholder = "sk-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"

                              proc changed(text: string) =
                                app.openai.apiKey = text

                          ActionRow:
                            title = "API url"
                            subtitle = "An API base url"
                            Entry {.addSuffix.}:
                              text = app.openai.apiBase

                              proc changed(text: string) =
                                app.openai.apiBase = text

                          ActionRow:
                            title = "Model"
                            subtitle = "An AI model to use for inference"
                            Entry {.addSuffix.}:
                              text = app.model
                              placeholder = "gpt-3.5-turbo"

                              proc changed(text: string) =
                                app.model = text

                          ActionRow:
                            title = "System Prompt"
                            subtitle = "A system prompt used for the model"
                            Entry {.addSuffix.}:
                              text = app.systemPrompt
                              placeholder = "You are a helpful assistant."

                              proc changed(text: string) =
                                app.systemPrompt = text
                                app.messages = @[]
                                app.messages.add(
                                  %*{
                                    "role": "system",
                                    "content": app.systemPrompt
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
