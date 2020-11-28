# Making a Website with shiny.router

This repository builds a website using the [`shiny.router`](https://cran.r-project.org/web/packages/shiny.router/index.html) package. The website brings together 2 shiny apps named `sentiment_wordcloud_app.R` and `text_summary.R` into a single shiny app described in `app.R`. 

The `sentiment_wordcloud_app.R` app allows the generation of positive and negative sentiment wordclouds. Given a piece of text, a wordcloud will be generated from the positive sentiment composite words and from the negative sentiment composite words. Read more about the approach taken [here](https://www.tidytextmining.com/sentiment.html#wordclouds).


The `text_summary.R` section allows the user to generate an extractive text summary given some input text. Extractive summarisation extracts the most important and meaningful sentences from an input text and forms a summary. Therefore you should expect to see sentences from the original input text to be present in the summary. Read more about the methods used [here](https://www.cs.bham.ac.uk/~pxt/IDA/text_summary.pdf).


Both services are very crude at this stage so there is no text cleaning under the hood (except for the removal of stop words and tokenisation). Thus it is the responsibility of the user to provide clean text as input.

The website on `app.R` is deployed on Azure App services and can be accessed [here](https://sentiment-wordcloud.azurewebsites.net/#!/).