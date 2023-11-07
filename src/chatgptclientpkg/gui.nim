import nigui
import nigui/msgBox

import threadpool
import strformat
import json

import os

import pyopenai

proc getOpenaiToken(envar: string): string =
  ## Gets OpenAI token from environment variable
  if not existsEnv(envar):
    echo(fmt"Environment variable {envar} is not set, you can get one here: https://platform.openai.com/account/api-keys")
    echo("add this:")
    echo(fmt"  export {envar}=your api key")
    echo("to your .bashrc or .zshrc")
    echo("or if you are on windows, edit environment variables in the settings")
    echo("alternatively you can temporarily set it in the gui settings")
  else:
    return getEnv(envar)

var api = OpenAiClient(
  apiKey: getOpenaiToken("OPENAI_API_KEY")
)
var model = "gpt-3.5-turbo"
var systemPrompt = "You are a helpful assistant."
var chatMessages: seq[JsonNode]
chatMessages.add(
  %*{
    "role": "system",
    "content": systemPrompt
  }
)

app.init()

var window = newWindow("Chat")
window.width = 600.scaleToDpi
window.height = 400.scaleToDpi

window.onCloseClick = proc(event: CloseClickEvent) =
  case window.msgBox("Do you want to quit?", "Quit?", "Yes", "No")
    of 1: window.dispose()
    else: discard

var container = newLayoutContainer(Layout_Horizontal)
window.add(container)

var menu = newLayoutContainer(Layout_Vertical)
menu.width = 150
menu.heightMode = HeightMode_Expand
menu.xAlign = XAlign_Center
menu.frame = newFrame("Menu")
container.add(menu)


var buttonChat = newButton("Chat")
buttonChat.width = 135
menu.add(buttonChat)

var buttonSettings = newButton("Settings")
buttonSettings.width = 135
menu.add(buttonSettings)


proc requestAnswerThread(args: (OpenAiClient, seq[JsonNode], TextArea, Button)) {.thread.} =
  var (openai, messages, chatDisplay, chatSendButton) = args

  let resp = openai.createChatCompletion(
     model = "gpt-3.5-turbo",
     messages = messages
  )
  messages.add(
    resp["choices"][0]["message"]
  )
  let output = resp["choices"][0]["message"]["content"].str
  chatDisplay.addLine(fmt"[AI]: {output}")

  chatDisplay.scrollToBottom()
  chatSendButton.enabled = true

proc requestAnswer(args: (OpenAiClient, seq[JsonNode], TextArea, Button)) =
  var (openai, messages, chatDisplay, chatSendButton) = args

  let resp = openai.createChatCompletion(
      model = model,
      messages = messages
  )
  messages.add(
      resp["choices"][0]["message"]
  )
  let output = resp["choices"][0]["message"]["content"].str
  chatDisplay.addLine(fmt"[AI]: {output}")

  chatDisplay.scrollToBottom()
  chatSendButton.enabled = true

# Chat
var chatArea = newLayoutContainer(Layout_Vertical)
container.add(chatArea)

var chatDisplay = newTextArea()
chatDisplay.editable = false
chatArea.add(chatDisplay)

var chatComponent = newLayoutContainer(Layout_Horizontal)

var chatTextBox = newTextBox()
chatComponent.add(chatTextBox)

var chatSendButton = newButton("send")
chatComponent.add(chatSendButton)

chatSendButton.onClick = proc(event: ClickEvent) =
  chatSendButton.enabled = false
  case chatTextBox.text
    of "clear":
      chatDisplay.text = ""
      chatMessages = @[]
      chatMessages.add(
        %*{
          "role": "system",
          "content": systemPrompt
        }
      )
      chatSendButton.enabled = true
    else:
      chatDisplay.addLine(fmt"[YOU]: {chatTextBox.text}")
      chatMessages.add(
          %*{
              "role": "user",
              "content": chatTextBox.text
        }
      )
      spawn requestAnswerThread((api, chatMessages, chatDisplay, chatSendButton))
  chatTextBox.text = ""

chatArea.add(chatComponent)

# Settings
var settingsArea = newLayoutContainer(Layout_Vertical)
settingsArea.visible = false
container.add(settingsArea)

var
  apiKeyInputComponent = newLayoutContainer(Layout_Horizontal)
  apiBaseInputComponent = newLayoutContainer(Layout_Horizontal)
  modelInputComponent = newLayoutContainer(Layout_Horizontal)
  systemPromptInputComponent = newLayoutContainer(Layout_Horizontal)


var apiKeyInputLabel = newLabel("API key:")
apiKeyInputLabel.heightMode = HeightMode_Fill
apiKeyInputComponent.add(apiKeyInputLabel)

var apiKeyInputField = newTextBox()
apiKeyInputField.text = api.apiKey
apiKeyInputComponent.add(apiKeyInputField)

settingsArea.add(apiKeyInputComponent)


var apiBaseInputLabel = newLabel("API url base:")
apiBaseInputLabel.heightMode = HeightMode_Fill
apiBaseInputComponent.add(apiBaseInputLabel)

var apiBaseInputField = newTextBox()
apiBaseInputField.text = api.apiBase
apiBaseInputComponent.add(apiBaseInputField)

settingsArea.add(apiBaseInputComponent)


var modelInputLabel = newLabel("Model:")
modelInputLabel.heightMode = HeightMode_Fill
modelInputComponent.add(modelInputLabel)

var modelInputField = newTextBox()
modelInputField.text = model
modelInputComponent.add(modelInputField)

settingsArea.add(modelInputComponent)


var systemPromptInputLabel = newLabel("System Prompt:")
systemPromptInputLabel.heightMode = HeightMode_Fill
systemPromptInputComponent.add(systemPromptInputLabel)

var systemPromptInputField = newTextBox()
systemPromptInputField.text = systemPrompt
systemPromptInputComponent.add(systemPromptInputField)

settingsArea.add(systemPromptInputComponent)


var saveButton = newButton("Save")
settingsArea.add(saveButton)

saveButton.onClick = proc(event: ClickEvent) =
  api.apiKey = apiKeyInputField.text
  api.apiBase = apiBaseInputField.text
  model = modelInputField.text
  systemPrompt = systemPromptInputField.text
  chatDisplay.text = ""
  chatMessages = @[]
  if systemPrompt != "":
    chatMessages.add(
      %*{
        "role": "system",
        "content": systemPrompt
      }
    )

buttonChat.onClick = proc(event: ClickEvent) =
  window.title = "Chat"
  chatArea.visible = true
  settingsArea.visible = false

buttonSettings.onClick = proc(event: ClickEvent) =
  window.title = "Settings"
  chatArea.visible = false
  settingsArea.visible = true

proc start*() =
  window.show()
  app.run()

proc stop*() =
  app.quit()
