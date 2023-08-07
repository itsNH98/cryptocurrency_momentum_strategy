## 0.1 - Packages -----------------------
library(gtrendsR)
library(stringr)
library(stlplus)
library(lubridate)
library(forecast)
# Note: This code doesn't work at the moment due to changes in the Google API 

#=======================================================#
# 1 - Data Gathering                                    #
#=======================================================#

## 1.1 - Cryptocurrency keywords  -------------------------

keywords <- c('1INCH', 'Aave', 'Cardano', 'Algorand', 'Alpha Finance', 'Aragon', 'Balancer','Basic Attention Token', 
              'Bitcoin Cash', 'Binance Coin', 'Bitcoin SV', 'Bitcoin -cash -gold -SV', 'Bitcoin Gold',
              'Compound coin', 'Crypto.com Coin', 'Curve DAO', 'Civic coin', 'Dash coin', 'Decred', 'DigiByte', 'Dogecoin',
              'Polkadot', 'Dragonchain', 'aelf coin', 'Ethereum Classic', 'Ethereum -classic', 'FTX Token', 'FunFair', 'Gas Coin',
              'Gnosis coin', 'Grin coin', 'HedgeTrade', 'Huobi Token', 'Internet Computer', 'Kyber Network',
              'Chainlink', 'Loom Network', 'Livepeer', 'Litecoin', 'MaidSafeCoin', 'Decentraland', 'Maker DAO', 'NEO',
              'Nexus Mutual', 'OMG Network', 'Paxos Standard', 'Paxos Gold', 'Perpetual Protocol',
              'Polymath', 'Power Ledger', 'Populous coin', 'QASH', 'Quant coin', 'Ren coin', 'Augur coin', 'Sai coin', 'Status coin',
              'Synthetix', 'Serum coin', 'SushiSwap', 'Swerve coin', 'TRON coin', 'UMA coin', 'Uniswap', 'Vertcoin',
              'Waltonchain', 'NEM coin', 'Stellar', 'Monero', 'XRP', 'Tezos', 'Verge coin',
              'yearn finance', 'Zcash', '0x coin')


# Dates vectors
# Returns data starts in early 2014
# We need overlapping dates to apply the knitting algorithm
weekGT <- c("2014-05-21 2017-05-21",
            "2016-05-21 2019-05-21",
            "2018-05-21 2021-05-21",
            "2020-05-21 2023-04-25") 

## 1.2 - Gathering with gtrends -----------------------

Sys.setenv(TZ = "UTC")
cryptoALL = list()
dateALL = list()
nameALL = c()
pos = 1 
start = Sys.time()

for(i in 1:length(keywords)) {
  crypto = list() 
  date = list()
  
  for (j in 1:length(weekGT)) {
    alt = gtrends(keywords[i], gprop = c("web", "news", "images", "froogle", "youtube"), 
                  time = weekGT[j], onlyInterest = TRUE)
    
    # Removing certain keywords that have not enough values 
    if(is.null(alt$interest_over_time)){ 
      change = 0 
      break
    }
    else {
      # Removing certain keywords that have not enough values. Only for a specific date this time
      crypto[[j]] = as.integer(alt[["interest_over_time"]][["hits"]])
      crypto[[j]][which(is.na(crypto[[j]]))] = 0 # ">1" --> 0
      date[[j]] = alt[["interest_over_time"]][["date"]]
      change = 1
    }
    Sys.sleep(2)
  }
  if(change==1) {
    cryptoALL[[pos]] = crypto
    dateALL[[pos]] = date
    nameALL[pos] = alt$interest_over_time$keyword[1]
    pos = pos + 1
  }
  Sys.sleep(2)
}

## 1.3 Knitting Algorithm by Bleher et Dimpfl (2021) ---------

weeklyData = list()
dateTest = list()

# For each crypto
for (i in 1:length(cryptoALL)) {
  
  # holders
  dateEmpA = list()
  dateEmpB = list()
  dateA = list()
  dateB = list()
  data = list()
  date = c()
  
  
  res = try( 
    # for the date block in all the date blocks given a variable
    for (j in 1:(length(cryptoALL[[i]])-1)) {
      
      samA = c()
      samB = c()
      
      if(j==1){
        # Finally, str_which() takes the first argument as the string to search within, 
        # and the second argument as the target string to find the position of. 
        # It returns the position(s) where the target string is found within the given string.
        
        # Basically: find me the indices of the variables where there is "2008", etc.
        dateEmpA[[j]] = str_which(dateALL[[i]][[j]], as.character(str_sub(weekGT[j+1],1,4)))
        print(dateEmpA)
        
        # find me the indices of the next variable where the values are "2008"
        dateEmpB[[j]] = str_which(dateALL[[i]][[j+1]],as.character(str_sub(weekGT[j+1],1,4)))
        
        
        # It's because there are overlapping dates in all  the databases 
        dateA[[j]] = dateALL[[i]][[j]][dateEmpA[[j]]]
        dateB[[j]] = dateALL[[i]][[j+1]][dateEmpB[[j]]]
        
        samA = cryptoALL[[i]][[j]][dateEmpA[[j]]]   
        samB = cryptoALL[[i]][[j+1]][dateEmpB[[j]]] 
        
        
        # We regress the set of new values on the set of old values to find the scale
        reg = lm(samB~samA-1)                           
        
        pred = summary(reg)[["coefficients"]][1,1]*cryptoALL[[i]][[j]]
        long = length(samA)
        data[[j]] = c(pred,cryptoALL[[i]][[j+1]][(long+1):length(cryptoALL[[i]][[j+1]])])
      } 
      else {
        dateEmpA[[j]] = str_which(dateALL[[i]][[j]],as.character(str_sub(weekGT[j+1],1,4)))
        dateEmpB[[j]] = str_which(dateALL[[i]][[j+1]],as.character(str_sub(weekGT[j+1],1,4)))
        
        dateA[[j]] = dateALL[[i]][[j]][dateEmpA[[j]]]
        dateB[[j]] = dateALL[[i]][[j+1]][dateEmpB[[j]]]
        
        samA = cryptoALL[[i]][[j]][dateEmpA[[j]]]
        samB = cryptoALL[[i]][[j+1]][dateEmpB[[j]]]
        
        reg = lm(samB~samA-1)
        pred = summary(reg)[["coefficients"]][1,1]*data[[j-1]]
        long = length(samA)
        data[[j]] = c(pred,cryptoALL[[i]][[j+1]][(long+1):length(cryptoALL[[i]][[j+1]])])
      }
    })
  if(inherits(res, "try-error")) next
  weeklyData[[i]] = data[[length(data)]]
  dateTest[[i]] = date
}
#

## 1.4 Cleaning (optional) and managing data ---------

# Removing Null values 

# nulle = c()
# pos = 1
# for (i in 1:length(weeklyData)) {
#   if(is.null(weeklyData[[i]])) {
#     nulle[pos] = i 
#     pos = pos + 1
#   }
# }
# 
# weeklyData <- weeklyData[-nulle]
# nameALL <- nameALL[-nulle]
# dateALL <- dateALL[-nulle]

# Conversion to dataframe

startDate <- "2014-05-21"
endDate <- "2023-04-25"
googleTable_w <- data.frame(seq(as.Date(startDate),as.Date(endDate),"1 week"))

pos <- 1
for (i in 1:length(nameALL)) {
  googleTable_w[,i+1] <- weeklyData[[i]]
}
colnames(googleTable_w) <- c("Date",nameALL)

pos <- nrow(googleTable_w)

googleTable_w_crypto <- googleTable_w
rownames(googleTable_w_crypto) <- googleTable_w_crypto$Date 
googleTable_w_crypto <- subset(googleTable_w_crypto, select= -Date)

write.csv(googleTable_w_crypto, file='./Documents/Work/research/main/investing/cryptocurrencies/data/googleTable_w_crypto.csv', row.names = TRUE)
#=======================================================#
# 2 -     Data cleaning and Preparation                 #
#=======================================================#
# 
# ## 2.1 Handling of Zero Values ------------
# 
# # Calculate the proportions of zeros in each column
# zeros_proportions <- colMeans(googleTable_w_can == 0)
# 
# # Filter out columns with proportions greater than the threshold
# gt_w_can_clean <- googleTable_w_can[, zeros_proportions <= 0.05]
# 
# 
# ## 2.2 Handling of Non-Stationary Variables  ------------
# # We use the ADF test to determine which time-series are non-stationary, removing them after
# # We might think of taking the first difference at some point rather than removing them
# 
# pvalue_df <- data.frame(column_name = character(), p_value = numeric(), stringsAsFactors = FALSE)
# 
# for (col_name in colnames(gt_w_can_nozeros)) {
#   # Perform ADF test on the column
#   result <- adf.test(gt_w_can_nozeros[[col_name]])
# 
#   # Extract the p-value from the test result
#   p_value <- result$p.value
# 
#   # Create a new row in the results DF
#   new_row <- data.frame(column_name = col_name, p_value = p_value)
# 
#   # Append the new row to the results DF
#   pvalue_df <- rbind(pvalue_df, new_row)
# 
# }
# 
# pvalue_df <- pvalue_df[order(-pvalue_df$p_value), ]
# stationary_vars <- pvalue_df$column_name[pvalue_df$p_value > 0.01]
# 
# gt_w_can_clean <- gt_w_can_clean[, setdiff(names(gt_w_can_clean), stationary_vars)]
# 
# 
# ## 2.3 Handling of Seasonality   ------------
# # We decompose the time-series into its seasonal, trend and remainder component
# 
# # Create an empty dataframe to store the remainder values
# gt_w_can_clean_deseasoned <- data.frame(row.names = rownames(gt_w_can_clean))
# 
# # Iterate over each column index of the panel data
# for (col in 1:ncol(ts_google)) {
#   # Extract the column data
#   column_data <- ts_google[, col]
# 
#   # Apply STL decomposition on the column
#   decomposition <- stl(column_data, s.window = "periodic")  # Adjust the s.window parameter as per your data
# 
#   # Extract the remainder values
#   remainder <- decomposition$time.series[, "remainder"]
# 
#   # Assign the remainder values to the new dataframe
#   gt_w_can_clean_deseasoned <- cbind(gt_w_can_clean_deseasoned, remainder)
# }
# 
# # Rename the columns of the gt_w_can_clean_deseasoned dataframe with the original variable names
# colnames(gt_w_can_clean_deseasoned) <- colnames(ts_google)

