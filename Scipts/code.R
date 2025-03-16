library(textclean)    
library(textstem)     
library(tidytext)     
library(dplyr)
library(SnowballC)  # For stemming

# Load data
text_data <- readLines("Data/en_US/en_US.blogs.txt", n = 4000)

# Convert to lowercase
text_data <- tolower(text_data)

# Expand contractions
text_data <- replace_contraction(text_data)

# Fix possessives (e.g., "ellen s" -> "ellen's")
text_data <- gsub("([a-z]+) s ", "\\1's ", text_data)

# Preserve number-word associations
text_data <- gsub("([0-9]+) ([a-z]+)", "\\1_\\2", text_data)

# Remove special characters but **keep** apostrophes
text_data <- gsub("[^a-z0-9' ]", " ", text_data)

# Remove extra whitespace
text_data <- gsub("\\s+", " ", text_data)
text_data
# Convert to tibble
text_tibble <- tibble(text = text_data)

# Tokenize words while keeping apostrophes
tokens <- text_tibble %>%
        unnest_tokens(word, text, token = "words") %>%
        mutate(word = SnowballC::wordStem(word, "en")) %>%  # Stemming first
        mutate(word = lemmatize_words(word))  # Then lemmatization

# Print cleaned output
print(tokens)




