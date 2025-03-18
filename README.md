# Text Analysis and Prediction Project

## Overview
This project focuses on processing and analyzing large-scale text data from blogs, news articles, and Twitter. The goal is to clean and tokenize the data, perform exploratory data analysis (EDA), and build a simple next-word prediction model based on unigrams, bigrams, and trigrams.

## Folder Structure
```r
project_root/
    │-- Data/                   # Contains text data files
│   │-- en_US.blogs.txt
│   │-- en_US.news.txt
│   │-- en_US.twitter.txt
│-- Output/                 # Stores generated plots and results
        │-- text_analysis.R         # Main R script for text processing and analysis
│-- README.md               # Project documentation
```

## Installation & Dependencies
To run this project, ensure you have R installed along with the required packages. You can install the necessary dependencies using:
        
```r
install.packages(c("textclean", "textstem", "tidytext", "dplyr", "SnowballC", "stringr", "ggplot2"))
```

## Dataset Information
The project processes three text datasets:
        - `en_US.blogs.txt`: Blog entries
- `en_US.news.txt`: News articles
- `en_US.twitter.txt`: Tweets

Each dataset contains a large number of lines, and a subset of 50,000 lines is used for analysis.

## Data Processing & Cleaning
1. Convert text to lowercase.
2. Expand contractions (e.g., "can't" → "cannot").
3. Fix possessives (e.g., "John s" → "John's").
4. Preserve number-word associations (e.g., "8 first" → "8_first").
5. Remove special characters while keeping apostrophes.
6. Remove extra whitespace.

## Tokenization & Stopword Removal
- Text is tokenized into words.
- Words are stemmed and lemmatized.
- Common stopwords are removed to enhance analysis.

## Exploratory Data Analysis (EDA)
Various visualizations are created to understand word frequency distribution:
1. **Top 10 Most Frequent Words** - A bar chart showing the most common words.
2. **Word Frequency Distribution** - A histogram showing word count distribution.
3. **Cumulative Word Coverage** - Determines the number of words needed to cover 50% and 90% of the total dataset.
4. **Zipfs Law Distribution** - A log-log plot showing word frequency ranking.

All plots are saved in the `Output/` folder.

## Next-Word Prediction Model
A simple next-word prediction model is implemented using:
- **Trigram lookup**: Predicts the next word based on the last two words.
- **Bigram lookup**: If no trigram match is found, predicts based on the last word.
- **Unigram fallback**: If no bigram match is found, predicts the most frequent word.

### Example Usage
```r
predict_next_word_simple("the weather is")
```
This function returns the most probable next word.

## Running the Code
To execute the script, simply run:
```r
source("text_analysis.R")
```
Ensure that the `Data/` folder contains the necessary text files before running the script.

## Expected Outputs
- Cleaned text dataset
- Tokenized words with stemming and lemmatization
- Word frequency statistics
- Plots saved in the `Output/` folder
- A functional next-word prediction system

## Future Enhancements
- Implementing a deep learning-based language model.
- Improving prediction accuracy with a larger n-gram model.
- Integrating additional text sources for better generalization.

## Contributors
- **Hevar** - Developer & Analyst
