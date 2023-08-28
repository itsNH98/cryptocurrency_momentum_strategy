import pandas as pd
import sys
import datetime
import os

def main():
    if len(sys.argv) != 5:
        print("Usage: python script.py <date> <allocation_long> <allocation_short> <NAV>")
        return

    date_str = sys.argv[1]
    allocation_long = sys.argv[2].split(';')
    allocation_short = sys.argv[3].split(';')
    nav = float(sys.argv[4])

    # Path to the allocation CSV file
    input_path = '../results/allocation.csv'

    # Check if the allocation CSV file exists
    if os.path.exists(input_path):
        # Load the existing CSV file into a DataFrame
        allocation = pd.read_csv(input_path)
    else:
        # Create a new DataFrame if the file doesn't exist
        allocation = pd.DataFrame(columns=['Date', 'Allocation_Long', 'Allocation_Short', 'EOW_Returns', 'NAV'])

    # Prepare the new row to be added
    new_row = {
        'Date': date_str,
        'Allocation_Long': allocation_long,
        'Allocation_Short': allocation_short,
        'EOW_Returns': 'TBD',  # Placeholder for now
        'NAV': nav
    }

    # Add the new row to the DataFrame
    allocation = pd.concat([allocation, pd.DataFrame(new_row, index=[0])], ignore_index=True)

    # Convert 'Date' column to datetime format
    allocation['Date'] = pd.to_datetime(allocation['Date'])

    # Calculate EOW_Returns as the future NAV / actual NAV
    allocation['EOW_Returns'] = (allocation['NAV'].shift(-1) / allocation['NAV'])-1

    # Save the updated DataFrame back to the CSV file
    allocation.to_csv(input_path, index=False)
    print("Allocation data updated and saved to:", input_path)

if __name__ == "__main__":
    main()
