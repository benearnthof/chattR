library(shiny)
library(shiny.collections)

connection <- shiny.collections::connect()

get_random_username <- function() {
  paste0("User", round(runif(1, 10000, 99999)))
}

ui <- shinyUI(fluidPage(
  titlePanel("chattR"),
  div(textInput("username_field", "Username", width = "200px")),
  uiOutput("chatbox"),
  div(style = "display:inline-block",
      textInput("message_field", "Your message", width = "500px")),
  div(style = "display:inline-block",
      actionButton("send", "Send"))
))

server <- shinyServer(function(input, output, session) {
  # initialize user with a random name upon starting a session
  updateTextInput(session, "username_field",
                  value = get_random_username()
  )
  # observe updates to username and message
  observeEvent(input$send, {
    new_message <- list(user = input$username_field,
                        text = input$message_field,
                        time = Sys.time())
    shiny.collections::insert(chat, new_message)
    updateTextInput(session, "message_field", value = "")
  })
  # construct chatbox as renderUI
  output$chatbox <- renderUI({
    if (!is_empty(chat$collection)) {
      render_msg_divs(chat$collection)
    } else {
      tags$span("Empty chat")
    }
  })
  
  
  
})

shinyApp(ui = ui, server = server)
