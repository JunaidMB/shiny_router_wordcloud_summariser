library(shiny)
library(glue)
source("helper_functions.R")


# Define UI for app ----
ui <- fluidPage(
  
  titlePanel("Text Summarisation"),
  
  fluidRow(
    column(4,
           h2("Enter Text to Summarise") 
    )
    
  ),
  
  fluidRow(
    column(4,
           h5("Read more about the summarisation methods", tags$a(href = "https://www.cs.bham.ac.uk/~pxt/IDA/text_summary.pdf", "here", target = "_blank"))
    )
    
  ),
  
  fluidRow(
    column(10,
           textAreaInput(inputId = "input_text", label = "Input Text - Format them as sentences", width = "1000px", height = "250px")     
    )
  ),
  
  fluidRow(
    column(4,
           numericInput(inputId = 'sentence_number', label = 'Number of Sentences to Return', value = 2, min = 1)
    ),
    
  ),
  
  fluidRow(
    column(4,
           actionButton(inputId = "run", label = "Summarise Text")
    )
  ),
  
  fluidRow(
    column(4,
           h2("Summarised Text")
    )
  ),
  
  fluidRow(
    column(12,
           wellPanel(
             tabsetPanel(type = "tabs",
                         tabPanel("Relevance", textOutput("relevance_summary")),
                         tabPanel("SVD", textOutput("svd_summary"))
             )
           )
    )
  )
  
  
)

# Define server logic required to draw a histogram ----
server <- function(input, output, session) {
  
  
  relevance_summarised_text <- eventReactive(input$run, {
    
   
           relevance_based_summary(document = input$input_text, sentences_to_return = input$sentence_number)
    
    
  })
  
  svd_summarised_text <- eventReactive(input$run, {
    
    
    svd_based_summary(document = input$input_text, sentences_to_return = input$sentence_number)
    
    
  })
  
  
  
  
  output$relevance_summary <- renderText({  relevance_summarised_text()  })
  
  output$svd_summary <- renderText({  svd_summarised_text()  })
  
  
  
}

shinyApp(ui = ui, server = server)

