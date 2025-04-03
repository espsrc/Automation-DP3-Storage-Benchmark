#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import pandas as pd
import re
import argparse
import matplotlib.pyplot as plt
import seaborn as sns
import matplotlib.dates as mdates


def parse_log_file(file_path):
    """
    Reads a benchmark log file and extracts relevant execution time statistics.

    Parameters:
        file_path (str): Path to the benchmark log file.

    Returns:
        pd.DataFrame: DataFrame containing extracted benchmark data.
    """
    try:
        with open(file_path, "r", encoding="utf-8") as file:
            data_text = file.read()
    except FileNotFoundError:
        print(f"Error: File '{file_path}' not found.")
        exit(1)
    except Exception as e:
        print(f"Error reading file: {e}")
        exit(1)

    # Regular expression pattern to extract relevant information
    pattern = re.compile(
        r"""
        (CINDER|MANILA|LOCAL-DISK):\sTODAY\sIS\s(\d{2}/\d{2}/\d{4})\sAND\sTHE\sCURRENT\sTIME\sIS?\s(\d{2}:\d{2}:\d{2})\sUTC[\s\S]+?
        Average\sexecution\stime\s([\d.]+)\sseconds[\s\S]+?
        Max\sexecution\stime\s([\d.]+)\sseconds[\s\S]+?
        Std\sdev\sof\sexecution\stime\s([\d.]+)\sseconds[\s\S]+?
        DONE\s(\d{2}:\d{2}:\d{2})\sUTC
        """,
        re.DOTALL | re.VERBOSE | re.IGNORECASE
    )

    # Extract data using the regex pattern
    matches = pattern.findall(data_text)

    # Create a DataFrame with extracted data
    df = pd.DataFrame(
        matches,
        columns=[
            "Storage",
            "Date",
            "Start Time",
            "Avg Execution Time",
            "Max Execution Time",
            "Std Dev Execution Time",
            "End Time",
        ],
    )

    # Convert numerical columns to float for proper analysis
    numeric_cols = ["Avg Execution Time",
                    "Max Execution Time",
                    "Std Dev Execution Time"]
    df[numeric_cols] = df[numeric_cols].astype(float)

    # Convert to Date type
    df['Date'] = pd.to_datetime(df['Date'], format='%d/%m/%Y')

    # Convert to hour type
    df['Start Time'] = pd.to_datetime(df['Start Time'],
                                      format='%H:%M:%S').dt.time
    df['End Time'] = pd.to_datetime(df['End Time'],
                                    format='%H:%M:%S').dt.time

    return df


def plot_execution_time(df):
    # Sort the DataFrame by date and time
    df = df.sort_values(by=['Date', 'Start Time'])

    # Convert 'Start Time' to datetime by combining it with 'Date'
    df['Datetime'] = df['Date'] + pd.to_timedelta(df['Start Time'].astype(str))

    # Create the figure and subplots
    fig, axes = plt.subplots(3, 1, figsize=(12, 12), sharex=True)

    metrics = ['Avg Execution Time',
               'Max Execution Time', 'Std Dev Execution Time']

    for i, (ax, metric) in enumerate(zip(axes, metrics)):
        sns.lineplot(data=df, x='Datetime', y=metric,
                     hue='Storage', marker='o', ax=ax)
        ax.set_ylabel(metric)
        ax.grid(True)

        # Show the legend only in the first subplot
        if i == 0:
            ax.legend(title='Storage', loc='upper right')
        else:
            ax.get_legend().set_visible(False)

    # Show only the first time of each day and include the weekday
    ax = axes[-1]
    # Get the first time of each day
    df_unique_times = df.groupby(df['Date']).first().reset_index()
    # Mark only the first appearance of the day
    ax.set_xticks(df_unique_times['Datetime'])
    # Date, day of week, and time format
    ax.xaxis.set_major_formatter(mdates.DateFormatter('%A, %Y-%m-%d %H:%M'))
    plt.xticks(rotation=45)

    # Remove the xlabel (this will prevent "Datetime" from appearing)
    plt.xlabel('')
    plt.tight_layout()

    # Display the plot
    plt.show()


def main():
    """Main function to parse arguments and process the log file."""
    parser = argparse.ArgumentParser(
        description="Process a benchmark logFile.")
    parser.add_argument("file", type=str, help="Path to the benchmark logFile")
    args = parser.parse_args()

    df = parse_log_file(args.file)

    # Display the DataFrame
    print(df)

    # Save DataFrame to a CSV file
    df.to_csv("execution_times.csv", index=False)

    # Call the function to plot
    plot_execution_time(df)


if __name__ == "__main__":
    main()
