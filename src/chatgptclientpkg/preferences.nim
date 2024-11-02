import owlkettle
import owlkettle/adw


viewable PreferencesDialog:
  apiKey: string
  apiBase: string
  model: string
  systemPrompt: string

method view(dialog: PreferencesDialogState): Widget =
  result = gui:
    Dialog:
      title = "Preferences"

      Box:
        orient = OrientY
        spacing = 12

        PreferencesGroup:
          title = "General"

          ActionRow:
            title = "API Key"
            subtitle = "An API Key to use for requests"
            Entry {.addSuffix.}:
              text = dialog.apiKey
              placeholder = "sk-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"

              proc changed(text: string) =
                dialog.apiKey = text

          ActionRow:
            title = "API url"
            subtitle = "An API base url"
            Entry {.addSuffix.}:
              text = dialog.apiBase

              proc changed(text: string) =
                dialog.apiBase = text

          ActionRow:
            title = "Model"
            subtitle = "An AI model to use for inference"
            Entry {.addSuffix.}:
              text = dialog.model
              placeholder = "gpt-3.5-turbo"

              proc changed(text: string) =
                dialog.model = text

          ActionRow:
            title = "System Prompt"
            subtitle = "A system prompt used for the model"
            Entry {.addSuffix.}:
              text = dialog.systemPrompt
              placeholder = "You are a helpful assistant."

              proc changed(text: string) =
                dialog.systemPrompt = text

export PreferencesDialog
export PreferencesDialogState
