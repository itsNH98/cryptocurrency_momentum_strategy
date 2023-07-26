# gtrendsR sometimes has problems, this is to test the library
library(gtrendsR)

# GENERAL TEST -------------------------------------------------
# gtrends("Biden", 
#         gprop = 'web',
#         geo = 'US',
#         time = "2023-02-15 2023-04-14", onlyInterest = TRUE )

# CRYPTO TEST -------------------------------------------------
keywords <- c('aave', 'Cardano', 'Bitcoin -gold -cash')

df <- gtrends(keywords, time='today 12-m', onlyInterest = T)  


# We get :
# Error in interest_over_time(widget, comparison_item, tz) : 
#   Status code was not 200. Returned status code:429
# After deep research, there is no obvious solution to this, we have to wait
