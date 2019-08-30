library(shiny)
library(shinyjs)
  shinyUI(
  bootstrapPage(
    # define new layout
    div(
      class = "container-fluid",
      div(
        class = "row-fluid",
        tags$head(tags$title("chattR")),
        # create header
        div(
          class = "span6", style = "padding: 10px 0px;",
          h1("chattR"),
          h4("version 0.2")
        ), div(
          class = "span6", id = "timeout",
          print(Sys.time())
        )
      ),
      # main panel
      div(
        class = "row-fluid",
        mainPanel(
          uiOutput("chat"),
          fluidRow(
            div(
              class = "span10",
              textInput("entry", "")
            ),
            div(
              class = "span2 center",
              actionButton("send", "Send")
            )
          )
        ),
        # right sidebar
        sidebarPanel(
          textInput("user", "Your User ID:", value = ""),
          actionButton("confirmname", "Confirm"),
          tags$hr(),
          h5("Connected Users"),
          uiOutput("userList"),
          tags$hr(),
          helpText(HTML("<p>Source code on <a href =\"https://github.com/benearnthof/chattr\">GitHub</a>."))
        )
      )
    )
  )
)
