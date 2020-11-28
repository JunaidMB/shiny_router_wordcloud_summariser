library(tidyverse)
library(tidytext)
library(tokenizers)
library(philentropy)

# Function to create a term frequency vector
term_occurences <- function(input, vocabulary) {
  input <- table(input)
  occurences <- as.vector(input[match(vocabulary, names(input))])
  occurences <- ifelse(is.na(occurences), 0, occurences)
  
  return(occurences)
}

# Relevance based summary
relevance_based_summary <- function(document, sentences_to_return = 1) {
  
  summary <- list()
  for (i in 1:sentences_to_return) {
    # Decompose a document into individual sentences and use these sentences to form the candidate sentence set S
    S <- unlist(tokenize_sentences(document))
    
    # Create a weighted term-frequency vector Ai for each sentence i in S, and the weighted term-frequency vector D for the whole document
    ## Obtain a tokenised vocabulary
    vocabulary <- unique(unlist(tokenize_words(document)))
    
    ## Determine term frequency vector for each passage
    S_tokenised <- tokenize_words(S)
    
    Ti <- lapply(S_tokenised, term_occurences, vocabulary = vocabulary)
    
    D <- term_occurences(input = unlist(tokenize_words(document)), vocabulary = vocabulary)
    
    A <- lapply(Ti, function(x) {x*D})
    
    # For each sentence i \in S, compute the relevance score between A and D which is the inner product between A and D
    
    R <- lapply(A, inner_product, D, testNA = TRUE)
    
    # Find index of the maximum
    max_index <- which.max(unlist(R))
    
    # Selected sentence
    k <- S[[max_index]]
    
    # Insert the selected sentence into the summary
    summary[[i]] <- k
    
    # Delete k from S and eliminate all terms contained in k from the document.
    S[[max_index]] <- NA
    S <- S[!is.na(S)]
    
    document <- paste(S, collapse = " ")
    
  }
  
  summary <- unlist(summary)
  
  return(summary)
  
}

# SVD based summary
svd_based_summary <- function(document, sentences_to_return = 1) {
  
  summary <- list()
  for (i in 1:sentences_to_return) {
    
    # Decompose a document into individual sentences and use these sentences to form the candidate sentence set S
    S <- unlist(tokenize_sentences(document))
    
    # Create a weighted term-frequency vector Ai for each sentence i in S, and the weighted term-frequency vector D for the whole document
    ## Obtain a tokenised vocabulary
    vocabulary <- unique(unlist(tokenize_words(document)))
    
    ## Determine term frequency vector for each passage
    S_tokenised <- tokenize_words(S)
    
    Ti <- lapply(S_tokenised, term_occurences, vocabulary = vocabulary)
    
    D <- term_occurences(input = unlist(tokenize_words(document)), vocabulary = vocabulary)
    
    A <- lapply(Ti, function(x) {x*D})
    
    # Cast A as a matrix
    A_mat <- matrix(unlist(A), nrow = length(vocabulary))
    
    # Perform SVD on A
    singular_value_decomp <- svd(A_mat)
    
    # Isolate V^T matrix
    V <- singular_value_decomp$v
    
    largest_index <- which.max(abs(V[,i]))  
    
    # Selected sentence
    k <- S[[largest_index]]
    
    # Insert the selected sentence into the summary
    summary[[i]] <- k
    
  }
  
  return(unlist(summary))
  
}

