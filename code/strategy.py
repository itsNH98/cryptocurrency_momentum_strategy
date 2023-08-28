# Python file for Cryptocurrency momentum strategy 
# To easily run from terminal, perhaps will add a cron job to do it automatically 

import requests
from bs4 import BeautifulSoup
from cryptocmd import CmcScraper
import pandas as pd
import numpy as np

import datetime

###=== UNIVERSE SCRAPER ===###

url = "https://coinmarketcap.com/"
response = requests.get(url)

soup = BeautifulSoup(response.content, "html.parser")
table = soup.find("table")

rows = table.find_all("tr")

ticker_list = []

for i, row in enumerate(rows[1:101]): # exclude header row
    if i < 10:
        ticker = row.find("a", {"class": "cmc-link"}).find('p', {'class': 'coin-item-symbol'}).text
    else:
        ticker = row.find("a", {"class": "cmc-link"}).find("span", {"class": "crypto-symbol"}).text

    ticker_list.append(ticker)

###=== CLEANING AND SELECTION OF THE UNIVERSE ===###

no_trades = ['USD', 'DAI', 'WBTC', 'WETH']

for i in range(len(no_trades)):    
    ticker_list = [x for x in ticker_list if no_trades[i] not in x]

top_twenty_mktcap = ticker_list[:20]

###=== PRICE SCRAPPER ===###
start_date = (datetime.date.today() - datetime.timedelta(14)).strftime('%d-%m-%Y')
end_date = (datetime.date.today()).strftime('%d-%m-%Y')

# Inital DF with Bitcoin 
scraper = CmcScraper("BTC", start_date, end_date)
df = pd.DataFrame(scraper.get_dataframe(date_as_index=True)['Close']).rename(columns={'Close':'BTC'})

for crypto in top_twenty_mktcap[1:]:
    scraper = CmcScraper(str(crypto), start_date, end_date)
    df = pd.merge(df, pd.DataFrame(scraper.get_dataframe(date_as_index=True)['Close']).rename(columns={'Close':str(crypto)}), left_index=True, right_index=True)
price_df = df[::-1]


def output_strategy(n_ls, data, output_sort=False):
    """
    Calculate the cumulative returns for the past week and identify the top and
    bottom performing stocks based on the cumulative returns.

    Parameters:
    ----------
    n_ls : int
        The number of top and bottom performing stocks to identify.
    data : pandas.DataFrame
        A DataFrame containing stock price data. It is assumed that the DataFrame
        has a datetime index and columns representing stock prices.
    output_sort : bool, optional
        If True, print the sorted cumulative returns before identifying top and
        bottom performing stocks. Default is False.

    Returns:
    -------
    top_stocks : numpy.ndarray
        An array of length n_ls containing the tickers (index labels) of the top
        performing stocks based on cumulative returns.
    bottom_stocks : numpy.ndarray
        An array of length n_ls containing the tickers (index labels) of the bottom
        performing stocks based on cumulative returns.
    """



    # Cumulative Returns for the Past Week
    log_ret_df = np.log(1 + data.pct_change())
    cum_returns = log_ret_df.apply(lambda x: x.sum())

    if output_sort == True:
        print(cum_returns.sort_values(ascending=False))
    

    top_stocks = cum_returns.sort_values(ascending=False).index[:n_ls].values
    bottom_stocks = cum_returns.sort_values(ascending=True).index[:n_ls].values

    return top_stocks, bottom_stocks

to_long, to_short = output_strategy(3, price_df, output_sort=True)

available_gmx = ['ETH', 'BTC', 'LINK', 'ARB', 'UNI', 'SOL', 'DOGE', 'XRP', 'LTC']

gmx_to_short = [value for value in to_short if value in available_gmx]
gmx_to_long = [value for value in to_long if value in available_gmx]

print(f'To long {gmx_to_long}')
print(f'To short {gmx_to_short}')