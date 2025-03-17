library(textclean)    
library(textstem)     
library(tidytext)     
library(dplyr)
library(SnowballC)  # For stemming
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
        unnest_tokens(word, text, token = "words") %>%
        mutate(word = SnowballC::wordStem(word, "en")) %>%  
        mutate(word = lemmatize_words(word))               

# Convert stop_words to tibble for compatibility
stop_words_tbl <- as_tibble(stop_words) %>%
        rename(word = value)

# Remove stop words
tokens <- tokens %>%
        anti_join(stop_words_tbl, by = "word")

# Check final processed words
head(tokens)
text_tibble
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





