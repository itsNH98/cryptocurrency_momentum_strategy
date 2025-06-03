# Attention-Momentum Crypto Trading Strategy

The author would like to thank Hugo Couture for his contribution to the project. Thanks Hugo ! 

**Note: Consider this as an ongoing project for future purposes. Not intended to be published in its actual state.**

# Abstract

This research project presents a crypto-based trading strategy that integrates price momentum, size, and investor attention to create a robust and efficient investment approach. The foundation of the strategy is derived from the research conducted by Yang (2019), Liu (2021), and Liu (2022), which collectively support the inclusion of price momentum, size and attention in the trading framework. We find consistent evidence for price momentum across various timeframes, particularly in the 1 to 3 weeks estimation window, complemented by weekly rebalancing.

Additionally, we examine the size factor in the cryptocurrency market, wherein smaller cryptos are believed to exhibit a premium due to their illiquidity. However, considering Liu's findings (2021 & 2022), momentum is more pronounced in larger and more widely recognized cryptocurrencies. Consequently, we implement a component to restrict the universe of tradable assets to the 15 cryptocurrencies with the highest market capitalization at the time.

To gauge investor attention, we employ Google searches as a proxy, using Bleher's (2022) methodology to knit the weekly information. While most of the project is done in the Python programming language, this part is done in R due to the gtrendsR library being more reliable than pytrends. As in the papers outlined previously, we categorize cryptocurrencies in two groups depending on the magnitude of the increase in their popularity over the past estimation period. Incorporating this information, we construct a quintile attention-informed momentum portfolio based on past week cumulative returns and perform a Long-Short (LS) strategy to optimize returns.

Overall, our crypto-based trading strategy combines price momentum, size, and investor attention to create a well-rounded and dynamic investment approach. The strategy's focus on larger cryptocurrencies with significant investor attention seeks to enhance performance while minimizing exposure to the less-liquid, smaller assets. This is beneficial both in terms of trading costs and complexity. Backtesting and performance evaluation using historical data will be conducted to validate the effectiveness of the proposed strategy. Investors can potentially benefit from employing this strategy, especially in the cryptocurrency market, which is known for its rapid movements and diverse investment opportunities. However, like any investment approach, it is essential to exercise due diligence and risk management to achieve favorable outcomes.

## References 

Yang, Hanlin. "Behavioral anomalies in cryptocurrency markets." Available at SSRN 3174421 (2019).

Liu, Yukun, and Aleh Tsyvinski. "Risks and returns of cryptocurrency." The Review of Financial Studies 34.6 (2021): 2689-2727.

Liu, Yukun, Aleh Tsyvinski, and Xi Wu. "Common risk factors in cryptocurrency." The Journal of Finance 77.2 (2022): 1133-1177.

Bleher, Johannes, and Thomas Dimpfl. "Knitting Multi-Annual High-Frequency Google Trends to Predict Inflation and Consumption." Econometrics and Statistics 24 (2022): 1-26.
