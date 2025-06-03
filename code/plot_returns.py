import argparse
import pandas as pd
import matplotlib.pyplot as plt

def plot_cumulative_returns():
    # Load the CSV file into a pandas DataFrame
    df = pd.read_csv('../results/allocation.csv')

    # Calculate cumulative returns
    df['cumulative_returns'] = (1 + df['EOW_Returns']).cumprod() - 1

    # Plot the cumulative returns data
    plt.figure(figsize=(10, 6))
    plt.plot(df['cumulative_returns'], label='Cumulative Returns')
    plt.title('Cumulative Returns over Time')
    plt.xlabel('Week')
    plt.ylabel('Strategy cumulative returns')
    plt.legend()
    plt.grid(True)

    # Show the plot
    plt.show()

if __name__ == '__main__':
    # parser = argparse.ArgumentParser(description='Plot cumulative returns from a CSV file.')
    # parser.add_argument('csv_file', type=str, help='Path to the CSV file')
    # parser.add_argument('returns_column', type=str, help='Name of the returns column in the CSV file')
    # args = parser.parse_args()

    plot_cumulative_returns()
