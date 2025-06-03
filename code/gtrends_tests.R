# Author: Nicolas Harvie

library(gtrendsR)
library(tidyr)
library(dplyr)
library(zoo)

kw <- c('litecoin')
kw_two <- c('litecoin', 'cardano')

interest_df <- gtrends(kw, time = 'today 12-m', 
                       gprop = c("web"), 
                       onlyInterest = TRUE)$interest_over_time

interest_df_two <- gtrends(kw_two, time = 'today 12-m', 
                       gprop = c("web"), 
                       onlyInterest = TRUE)$interest_over_time

# ----

interest_df_weekly <- gtrends(kw, time = "2020-08-07 2023-08-07", 
                             gprop = c("web"), 
                             onlyInterest = TRUE)$interest_over_time

interest_df_weekly2 <- gtrends(kw, time = 'today+5-y', 
                              gprop = c("web"), 
                              onlyInterest = TRUE)$interest_over_time

interest_df_daily <- gtrends(kw, time = 'today 1-m', 
                       gprop = c("web"), 
                       onlyInterest = TRUE)$interest_over_time