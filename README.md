# DSCP

# Backoff Prediction Model for Word Prediction

## Overview

This project implements a **Backoff Prediction Model** to predict the next words in a sentence based on a given text corpus. The model uses **unigrams**, **bigrams**, and **trigrams** for prediction. It applies a backoff mechanism where the model first attempts to predict the next word using trigrams, and if no match is found, it falls back to bigrams and unigrams, respectively.

The model is built using **R** and relies on the frequency of n-grams in the provided text data for word prediction.

## Objective

The purpose of this project is to develop a model that can predict the next word in a sequence of text, with the ability to provide predictions based on a given corpus. The model uses the following n-gram levels for prediction:
1. **Trigram**: Last two words for predicting the next.
2. **Bigram**: Last word for predicting the next.
3. **Unigram**: The most frequent word from the corpus.

## How It Works

The model is implemented in **R** and follows these steps:
1. **Data Preprocessing**:
   - Load the text data.
   - Clean and preprocess the text (convert to lowercase, expand contractions, remove special characters, and lemmatize).
   - Tokenize the data into unigrams, bigrams, and trigrams.

2. **Prediction**:
   - Given an input sentence, the model predicts the next **n** words using the trigram, bigram, and unigram frequency tables.
   - It checks the trigram table first, followed by the bigram table, and finally, the unigram table.

3. **Backoff Mechanism**:
   - If no trigram match is found, it falls back to the bigram prediction.
   - If no bigram match is found, it resorts to the unigram prediction.

## Installation

To run this model, you will need the following packages installed in your R environment:

- **textclean**: For handling contractions.
- **textstem**: For lemmatization.
- **tidytext**: For tokenization.
- **dplyr**: For data manipulation.

To install the required libraries, you can use the following command in R:

```r
install.packages(c("textclean", "textstem", "tidytext", "dplyr"))
```

