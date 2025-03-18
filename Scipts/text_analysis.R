library(textclean)    
library(textstem)     
library(tidytext)     
library(dplyr)
library(SnowballC)  
library(stringr)

# Define file paths
blogs_file <- "Data/en_US/en_US.blogs.txt"
news_file <- "Data/en_US/en_US.news.txt"
twitter_file <- "Data/en_US/en_US.twitter.txt"

# Function to read and clean text data
read_and_clean_text <- function(file_path, n = 50000) {
        # Read first n lines
        lines <- readLines(file_path, n = n, warn = FALSE)
        
        # Convert to lowercase
        lines <- tolower(lines)
        
        # Expand contractions (e.g., "can't" -> "cannot")
        lines <- replace_contraction(lines)
        
        # Fix possessives (e.g., "ellen s" -> "ellen's")
        lines <- gsub("([a-z]+) s\\b", "\\1's", lines)
        
        # Preserve number-word associations (e.g., "8 first" -> "8_first")
        lines <- gsub("([0-9]+) ([a-z]+)", "\\1_\\2", lines)
        
        # Remove special characters but **keep** apostrophes
        lines <- gsub("[^a-z0-9' ]", " ", lines)
        
        # Remove extra whitespace
        lines <- str_squish(lines)
        
        return(lines)
}

# Read and clean data from all sources
blogs_data <- read_and_clean_text(blogs_file)
news_data <- read_and_clean_text(news_file)
twitter_data <- read_and_clean_text(twitter_file)

# Combine into one dataset
combined_data <- c(blogs_data, news_data, twitter_data)

# Convert to tibble
text_tibble <- tibble(text = combined_data)

# Tokenize words, apply stemming and lemmatization
tokens <- text_tibble %>%
        mutate(text = replace_contraction(text)) %>%
        unnest_tokens(word, text, token = "words") %>%
        mutate(word = SnowballC::wordStem(word, "en")) %>%
        mutate(word = lemmatize_words(word))           

# Convert stop_words to tibble for compatibility
stop_words_tbl <- as_tibble(stop_words) %>%
        rename(word = value)
stop_words_tbl <- stop_words_tbl %>%
        mutate(word = tolower(word))
stop_words_tbl <- stop_words_tbl %>%
        mutate(word = str_trim(word))

tokens <- tokens %>%
        mutate(word = str_trim(word))
tokens <- tokens %>%
        mutate(word = tolower(word))

tokens <- tokens %>%
        anti_join(stop_words_tbl, by = "word")


# Check final processed words
head(tokens)

#------------------------------------------------------------------------------#

# Exploratory Data Analysis (EDA)

## Word frequency
word_freq <- tokens %>%
        count(word, sort = TRUE) %>%
        filter(n > 10)  # Remove words that appear less frequently

## Top 10 most common words
top_words <- word_freq %>%
        top_n(10, n)


# Plotting the top 10 most frequent words
library(ggplot2)
ggplot(top_words, aes(x = reorder(word, n), y = n)) +
        geom_bar(stat = "identity", fill = "steelblue") +
        coord_flip() +
        labs(title = "Top 10 Most Frequent Words", x = "Words", y = "Frequency")



# Count word frequencies
word_freq <- tokens %>%
        count(word, sort = TRUE)

# Plot word frequency distribution
ggplot(word_freq, aes(n)) +
        geom_histogram(bins = 50, fill = "steelblue", color = "black") +
        scale_x_log10() + 
        theme_minimal() +
        labs(title = "Word Frequency Distribution",
             x = "Word Count (log scale)",
             y = "Frequency",
             caption = "Distribution of word frequencies in the dataset")

# Calculate cumulative coverage
word_freq <- word_freq %>%
        mutate(cumulative = cumsum(n) / sum(n))

# Find word count needed to cover 50% and 90% of the total words
words_50 <- word_freq %>% filter(cumulative >= 0.50) %>% slice(1) %>% pull(word)
words_90 <- word_freq %>% filter(cumulative >= 0.90) %>% slice(1) %>% pull(word)

cat("Words needed to cover 50% of instances:", which(word_freq$word == words_50), "\n")
cat("Words needed to cover 90% of instances:", which(word_freq$word == words_90), "\n")


# Calculate word frequencies
word_freq_plot <- word_freq %>%
        arrange(desc(n)) %>%
        mutate(rank = row_number())
ggplot(word_freq_plot, aes(x = rank, y = n)) +
        geom_line(color = "blue") +
        scale_x_log10() +  # Log scale for better visualization
        scale_y_log10() +  # Log scale to highlight power-law distribution
        labs(title = "Word Frequency Distribution (Zipf's Law)",
             x = "Word Rank (log scale)",
             y = "Word Frequency (log scale)") +
        theme_minimal()
#------------------------------------------------------------------------------#
# Create a custom stopwords vector
stop_words_vector <- c("i", "me", "my", "myself", "we", "our", "ours", 
                       "you", "your", "yours", "he", "him", "his", 
                       "she", "her", "hers", "it", "its", "they", "them", "their", "theirs",
                       "the", "a", "an", "and", "but", "if", "or", "as", "because", "until",
                       "while", "of", "at", "by", "for", "with", "about", "against", "between",
                       "into", "through", "during", "before", "after", "above", "below", "to",
                       "from", "up", "down", "in", "out", "on", "off", "over", "under", 
                       "again", "further", "then", "once", "here", "there", "when", "where",
                       "why", "how", "all", "any", "both", "each", "few", "more", "most", 
                       "other", "some", "such", "no", "nor", "not", "only", "own", 
                       "same", "so", "than", "too", "very", "s", "t", "can", "will", 
                       "just", "don", "should", "now", "d", "ll", "m", "o", "re", 
                       "ve", "y", "ain", "aren", "couldn", "didn", "doesn", "hadn", 
                       "hasn", "haven", "isn", "ma", "mightn", "mustn", "needn", 
                       "shan", "shouldn", "wasn", "weren", "won", "wouldn", 
                       "is", "am", "are", "was", "were", "be", "been", "being",
                       "have", "has", "had", "having", "do", "does", "did", "doing", 
                       "doesn’t", "didn’t", "hasn’t", "haven’t", "isn’t")


# Create Unigrams & Remove Stopwords
unigrams <- text_tibble %>%
        unnest_tokens(unigram, text, token = "words") %>%
        filter(!unigram %in% stop_words_vector)  # Remove stopwords from unigrams

# Create Bigrams & Remove Stopwords
bigrams <- text_tibble %>%
        unnest_tokens(bigram, text, token = "ngrams", n = 2) %>%
        separate(bigram, into = c("word1", "word2"), sep = " ") %>%
        filter(!word1 %in% stop_words_vector, !word2 %in% stop_words_vector) %>%  # Remove stopwords from bigrams
        unite(bigram, word1, word2, sep = " ")

# Create Trigrams & Remove Stopwords
trigrams <- text_tibble %>%
        unnest_tokens(trigram, text, token = "ngrams", n = 3) %>%
        separate(trigram, into = c("word1", "word2", "word3"), sep = " ") %>%
        filter(!word1 %in% stop_words_vector, !word2 %in% stop_words_vector, !word3 %in% stop_words_vector) %>%  # Remove stopwords from trigrams
        unite(trigram, word1, word2, word3, sep = " ")



# Count frequencies
unigram_freq <- unigrams %>%
        count(unigram, sort = TRUE)
bigram_freq <- bigrams %>%
        count(bigram, sort = TRUE)
trigram_freq <- trigrams %>%
      trigram_freq  count(trigram, sort = TRUE)

trigram_freq <- trigram_freq %>%
        filter(!is.na(trigram))


#------------------------------------------------------------------------------#
predict_next_word_simple <- function(input_text, top_n = 3) {
        # Clean input text
        input_text <- tolower(input_text)
        input_words <- unlist(strsplit(input_text, " "))
        
        # Get the last word (for bigram and trigram predictions)
        last_word <- tail(input_words, 1)
        last_two_words <- paste(tail(input_words, 2), collapse = " ")
        
        # Check for trigram match (using last two words)
        trigram_match <- trigram_freq %>%
                filter(grepl(paste0("^", last_two_words), trigram)) %>%
                top_n(top_n, n)  # Top N trigram predictions
        
        # If no trigram match, check for bigram match
        if (nrow(trigram_match) > 0) {
                predicted_word <- strsplit(trigram_match$trigram[1], " ")[[1]][3]
        } else {
                bigram_match <- bigram_freq %>%
                        filter(grepl(paste0("^", last_word), bigram)) %>%
                        top_n(top_n, n)
                
                # If no bigram match, fall back to unigram prediction
                if (nrow(bigram_match) > 0) {
                        predicted_word <- strsplit(bigram_match$bigram[1], " ")[[1]][2]
                } else {
                        # Filter out common unigrams (e.g., stop words) and select top N
                        unigram_match <- unigram_freq %>%
                                filter(!unigram %in% c("the", "i", "a", "of", "to", "and")) %>%
                                top_n(top_n, n)
                        
                        predicted_word <- unigram_match$unigram[1]
                }
        }
        
        return(predicted_word)
}
#------------------------------------------------------------------------------#

# Example usage
predict_next_word_simple("")


