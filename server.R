library(shiny)
library(stringr)

# store reactive data
vars <- reactiveValues(chat = NULL, users = NULL)
# use superassignment to recursively search for global variables
# chat log => replace with DB later
if (file.exists("chat.Rds")) {
  vars$chat <- readRDS("chat.Rds")
} else {
  vars$chat <- "You are using chattR v0.2."
}

# prefix for chat line
# \newline unless first line
linePrefix <- function() {
  if (is.null(isolate(vars$chat))) {
    return("")
  }
  return("<br />")
}

shinyServer(function(input, output, session) {
  # store reactive vars for session
  sessionVars <- reactiveValues(username = "")
  # init for initial username assignment on session init
  init <- FALSE
  # remove user on session end
  session$onSessionEnded(function() {
    isolate({
      vars$users <- vars$users[vars$users != sessionVars$username]
      vars$chat <- c(vars$chat, paste0(
        linePrefix(),
        tags$span(
          class = "user-exit",
          sessionVars$username,
          "left the chat."
        )
      ))
    })
  })

  # username change observer
  observe({
    # only update on confirmation
    input$confirmname
    if (!init) {
      # initial assignment of username
      sessionVars$username <- paste0("User", round(runif(1, 10000, 99999)))
      isolate({
        vars$chat <<- c(vars$chat, paste0(
          linePrefix(),
          tags$span(
            class = "user-enter",
            sessionVars$username,
            "joined the chat."
          )
        ))
      })
      init <<- TRUE
    } else {
      isolate({
        if (input$user == sessionVars$username || input$user == "") {
          return()
        }
        # update username
        vars$users <- vars$users[vars$users != sessionVars$username]
        # save changes to log
        vars$chat <<- c(vars$chat, paste0(
          linePrefix(),
          tags$span(
            class = "user-change",
            paste0("\"", sessionVars$username, "\""),
            " changed name to ",
            paste0("\"", input$user, "\"")
          )
        ))
        sessionVars$username <- input$user
      })
    }
    # add new name to list of connected users
    isolate(vars$users <- c(vars$users, sessionVars$username))
  })

  # keep username updated
  observe({
    updateTextInput(session, "user",
      value = sessionVars$username
    )
  })

  # keep list of connected users updated
  output$userList <- renderUI({
    tagList(tags$ul(lapply(vars$users, function(user) {
      return(tags$li(user))
    })))
  })

  # observe send event
  observe({
    if (input$send < 1) {
      return()
    }
    # add entry to log
    isolate({
      vars$chat <<- c(
        vars$chat,
        paste0(
          linePrefix(),
          tags$span(
            class = "username",
            tags$abbr(title = Sys.time(), sessionVars$username)
          ),
          ": ",
          tagList(input$entry)
        )
      )
    })
    # clear text entry field
    updateTextInput(session, "entry", value = "")
  })

  # dynamic ui for chat window
  output$chat <- renderUI({
    if (length(vars$chat) > 500) {
      # display only last 500 lines
      vars$chat <- vars$chat[(length(vars$chat) - 500):(length(vars$chat))]
    }
    # add database for persistent storage later
    saveRDS(vars$chat, "chat.Rds")
    HTML(vars$chat)
  })
})
