# Author: Nicolas Harvie

library(gtrendsR)
library(tidyr)
library(dplyr)
library(zoo)

# CRYPTO RETRIEVAL -------------------------------------------------
# Check if command-line arguments are provided
# Check if command-line arguments are provided
if (length(commandArgs(TRUE)) < 2) {
  stop("Please provide a list of tickers and the 'output_sort' flag as command-line arguments.")
}

# Extract inputs from command-line arguments
user_input_tickers <- strsplit(commandArgs(TRUE)[1], ",")[[1]]
output_sort <- as.logical(commandArgs(TRUE)[2])

# Rest of your code using user_input_tickers and output_sort
all_cryptos <- user_input_tickers


# Function to get interest data for a keyword set and pivot the results
get_and_pivot_interest <- function(keyword) {
  interest_df <- gtrends(keyword, time = "today 12-m", 
                         gprop = c("web", "news", "images", "froogle", "youtube"), 
                         onlyInterest = TRUE)$interest_over_time
  
  # Pivot the DataFrame to have keywords as columns and hits as values
  pivot_df <- interest_df %>%
    select(date, hits, keyword) %>%
    pivot_wider(names_from = keyword, values_from = hits)
  
  return(pivot_df)
}

# Get and pivot interest data for each keyword set
result_list <- list()

for (kw in all_cryptos) {
  pivot_long <- get_and_pivot_interest(kw)
  
  # Remove date column from all DataFrames except the first one
  if (length(result_list) > 0) {
    pivot_long <- pivot_long %>%
      select(-date)
  }
  
  result_list[[kw]] <- pivot_long
}

# Combine the results into a single DataFrame
combined_df <- do.call(cbind, result_list)

# Convert into standardized value by rolling median
standardized_attention <- combined_df[4:nrow(combined_df), -1] / rollapply(combined_df[,-1], width = 4, FUN = median)
row.names(standardized_attention) <- combined_df[4:nrow(combined_df),1]


standardized_attention[(nrow(standardized_attention)-3):nrow(standardized_attention),]