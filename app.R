library(shiny)
library(shiny.router)
library(glue)
library(dplyr)
library(tidytext)
library(stringr)
library(stringi)
library(wordcloud2)
source("helper_functions.R")


# This generates menu in user interface with links.
menu <- (
  tags$ul(
    tags$li(a(class = "item", href = route_link("/"), "Homepage")),
    tags$li(a(class = "item", href = route_link("wordcloud"), "Wordcloud by Sentiment")),
    tags$li(a(class = "item", href = route_link("text_summary"), "Text Summariser"))
  )
)

# This creates UI for each page.


# Assign the UI for each page and wrap it around a div()

root_page <- div(
  menu,
  
  titlePanel("Homepage"),
  
  p("This is the homepage. You can use the navigation tabs in the top right to use the different services."),
  
  br(),
  
  p("The Wordcloud by Sentiment section allows the generation of positive and negative sentiment wordclouds. Given a piece of text, a wordcloud will be generated from the positive sentiment composite words and from the negative sentiment composite words."),
  
  br(),
  
  p("The Text Summariser section allows the user to generate an extractive text summary given some input text. Extractive summarisation extracts the most important and meaningful sentences from an input text and forms a summary. Therefore you should expect
    to see sentences from the original input text to be present in the summary."),
  
  br(),
  
  p("Both services are very crude at this stage so there is no text cleaning under the hood (except for the removal of stop words and tokenisation). Thus it is the responsibility of the user to provide clean text as input.")
  
  
)

wordcloud_page <- div(
  menu,
  
  fluidPage(
    
    titlePanel("Sentiment Wordcloud"),
    
    fluidRow(
      column(4,
             h2("Enter Text to obtain Wordcloud.") 
      )
      
    ),
    
    fluidRow(
      column(10,
             textAreaInput(inputId = "input_text_wc", label = "Input Text - Format them as sentences", width = "1000px", height = "250px")     
      )
    ),
    
    fluidRow(
      column(4,
             actionButton(inputId = "wc_run", label = "Generate Wordcloud")
      )
    ),
    
    fluidRow(
      column(4,
             h2("Wordcloud by Sentiment")
      )
    ),
    
    fluidRow(
      column(12,
             tabsetPanel(type = "tabs",
                         tabPanel("Positive", wordcloud2Output("positive_wordcloud")),
                         tabPanel("Negative", wordcloud2Output("negative_wordcloud"))
             ) 
      )
    )
    
  )

)

text_summary_page <- div(
  menu,
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
           textAreaInput(inputId = "input_text_summary", label = "Input Text - Format them as sentences", width = "1000px", height = "250px")     
    )
  ),
  
  fluidRow(
    column(4,
           numericInput(inputId = 'sentence_number', label = 'Number of Sentences to Return', value = 2, min = 1)
    ),
    
  ),
  
  fluidRow(
    column(4,
           actionButton(inputId = "summarise_run", label = "Summarise Text")
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

# Callbacks on the server side for each page. Here we define the server side logic for each page.

root_callback <- function(input, output, session) {}

wordcloud_callback <- function(input, output, session) {
  positive_summarised_text <- eventReactive(input$wc_run, {
    
    text_df <- tibble(text = input$input_text_wc)
    
    tidy_textinput <- text_df %>% 
      unnest_tokens(word, text) 
    
    tidy_textinput %>% 
      anti_join(stop_words) %>% 
      inner_join(get_sentiments("bing")) %>% 
      filter(sentiment == "positive") %>% 
      count(word, sentiment, sort = TRUE) %>% 
      select(word, n)
    
  })
  
  negative_summarised_text <- eventReactive(input$wc_run, {
    
    text_df <- tibble(text = input$input_text_wc)
    
    tidy_textinput <- text_df %>% 
      unnest_tokens(word, text) 
    
    tidy_textinput %>% 
      anti_join(stop_words) %>% 
      inner_join(get_sentiments("bing")) %>% 
      filter(sentiment == "negative") %>% 
      count(word, sentiment, sort = TRUE) %>% 
      select(word, n)
    
  })
  
  
  
  output$positive_wordcloud <- renderWordcloud2({ wordcloud2::wordcloud2(data = positive_summarised_text(), size = .5) })
  
  output$negative_wordcloud <- renderWordcloud2({ wordcloud2::wordcloud2(data = negative_summarised_text(), size = .5) })
}

text_summary_callback <- function(input, output, session) {
  relevance_summarised_text <- eventReactive(input$summarise_run, {
    
    
    relevance_based_summary(document = input$input_text_summary, sentences_to_return = input$sentence_number)
    
    
  })
  
  svd_summarised_text <- eventReactive(input$summarise_run, {
    
    
    svd_based_summary(document = input$input_text_summary, sentences_to_return = input$sentence_number)
    
    
  })
  
  
  
  
  output$relevance_summary <- renderText({  relevance_summarised_text()  })
  
  output$svd_summary <- renderText({  svd_summarised_text()  })
}

# Homepage Shiny: This is the shiny UI and server for the page that serves up the website.

# Creates router. We provide routing path, a UI as
# well as a server-side callback for each page.
router <- make_router(
  route("/", root_page, root_callback),
  route("wordcloud", wordcloud_page, wordcloud_callback),
  route("text_summary", text_summary_page, text_summary_callback)
)

# Make output for our router in MAIN UI of Shiny app.
ui <- shinyUI(fluidPage(
  theme = "main.css",
  router$ui
))

# Plug router into Shiny server.
server <- shinyServer(function(input, output, session) {
  router$server(input, output, session)
})

# Run server in a standard way.
shinyApp(ui, server)