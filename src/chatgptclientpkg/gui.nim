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

var api = newOpenAiClient(getOpenaiToken("OPENAI_API_KEY"))

var chatMessages: seq[JsonNode]

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

proc requestAnswer(args: (OpenAiClient, seq[JsonNode], TextArea, Button, Window)) {.thread.} =
    var (openai, messages, chatDisplay, chatSendButton, window) = args

    try:
        let resp = openai.createChatCompletion(
            model = "gpt-3.5-turbo",
            messages = messages
        )
        
        messages.add(
            resp["choices"][0]["message"]
        )
        let output = resp["choices"][0]["message"]["content"].str
        chatDisplay.addLine(fmt"[AI]: {output}")
    except InvalidApiKey:
        window.alert("The API key that you provided is invalid")
    except NotFound:
        window.alert("The model that you selected does not exist")
    except InvalidParameters:
        window.alert("Some of the parameters that you provided are invalid")
    except OSError:
        window.alert("No Internet")
    except Defect:
        window.alert("Unknown Error")

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
            chatSendButton.enabled = true
        else:
            chatDisplay.addLine(fmt"[YOU]: {chatTextBox.text}")
            chatMessages.add(
                %*{
                    "role": "user",
                    "content": chatTextBox.text
                }
            )
            spawn requestAnswer((api, chatMessages, chatDisplay, chatSendButton, window))
    chatTextBox.text = ""

chatArea.add(chatComponent)

# Settings
var settingsArea = newLayoutContainer(Layout_Vertical)
settingsArea.visible = false
container.add(settingsArea)

var 
    apiKeyInputComponent = newLayoutContainer(Layout_Horizontal)
    apiBaseInputComponent = newLayoutContainer(Layout_Horizontal)

var apiKeyInputLabel = newLabel("API key:")
apiKeyInputLabel.heightMode = HeightMode_Fill
apiKeyInputComponent.add(apiKeyInputLabel)

var apiKeyField = newTextBox()
apiKeyField.text = api.apiKey
apiKeyInputComponent.add(apiKeyField)

settingsArea.add(apiKeyInputComponent)

var apiBaseInputLabel = newLabel("API url base:")
apiBaseInputLabel.heightMode = HeightMode_Fill
apiBaseInputComponent.add(apiBaseInputLabel)

var apiBaseField = newTextBox()
apiBaseField.text = api.apiBase
apiBaseInputComponent.add(apiBaseField)

settingsArea.add(apiBaseInputComponent)

var saveButton = newButton("Save")
settingsArea.add(saveButton)

saveButton.onClick = proc(event: ClickEvent) =
    api.apiKey = apiKeyField.text
    api.apiBase = apiBaseField.text

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
