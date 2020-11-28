library(shiny)
library(glue)
library(dplyr)
library(tidytext)
library(stringr)
library(stringi)
library(wordcloud2)


# Define UI for app ----
ui <- fluidPage(
  
  titlePanel("Sentiment Wordcloud"),
  
  fluidRow(
    column(4,
    h2("Enter Text to obtain Wordcloud.") 
           )
    
  ),
  
  fluidRow(
    column(10,
    textAreaInput(inputId = "input_text", label = "Input Text - Format them as sentences", width = "1000px", height = "250px")     
    )
  ),
  
  fluidRow(
    column(4,
    actionButton(inputId = "run", label = "Generate Wordcloud")
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

# Define server logic
server <- function(input, output, session) {
  

  positive_summarised_text <- eventReactive(input$run, {
    
    text_df <- tibble(text = input$input_text)
    
    tidy_textinput <- text_df %>% 
      unnest_tokens(word, text) 
    
    tidy_textinput %>% 
      anti_join(stop_words) %>% 
      inner_join(get_sentiments("bing")) %>% 
      filter(sentiment == "positive") %>% 
      count(word, sentiment, sort = TRUE) %>% 
      select(word, n)
    
  })
  
  negative_summarised_text <- eventReactive(input$run, {
    
    text_df <- tibble(text = input$input_text)
    
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

shinyApp(ui = ui, server = server)









































