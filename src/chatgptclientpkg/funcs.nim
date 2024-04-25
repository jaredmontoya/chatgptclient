import owlkettle


proc errorNotification*(text: string) =
  sendNotification(
    "error-notification",
    title = "Error",
    body = text,
    icon = "preferences-system-notifications",
    category = "im.error",
    priority = NotificationHigh
  )
