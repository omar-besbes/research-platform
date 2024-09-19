import json
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import glob

def select_file(file_pattern):
    files = sorted(glob.glob(file_pattern))
    
    if not files:
        print("No files found for the given pattern.")
        exit
    
    # Display the list of files
    print("Please select a file from the list:")
    for idx, file in enumerate(files):
        print(f"{idx + 1}: {file}")
    
    # Ask the user to select a file
    while True:
        try:
            choice = int(input("Enter the number of the file you want to select: ")) - 1
            if 0 <= choice < len(files):
                return files[choice], f'heatmap_{choice + 1}.png'
            else:
                print("Invalid choice. Please enter a valid number.")
        except ValueError:
            print("Invalid input. Please enter a number.")

# Function to load and parse the JSON data
def load_data(file_path):
    with open(file_path) as f:
        data = json.load(f)
    return data

# Function to process the raw data into lists
def process_data(data):
    cpu_values = []
    memory_values = []
    time_values = []
    cpu_usage_values = []
    memory_usage_values = []

    for entry in data:
        cpu = float(entry["config"]["cpu"].replace('m', '')) / 1000  # Convert millicores to cores
        memory = float(entry["config"]["memory"].replace('gi', ''))
        time = int(entry["metrics"]["totalTime"]) / 1000 # Convert milliseconds to seconds
        cpu_usage = float(entry["metrics"]["totalCpuUsage"])
        memory_usage = int(entry["metrics"]["totalMemoryUsage"]) / 1000 / 1000 / 1000 # Convert bytes to gigabytes
        
        cpu_values.append(cpu)
        memory_values.append(memory)
        time_values.append(time)
        cpu_usage_values.append(cpu_usage)
        memory_usage_values.append(memory_usage)

    return cpu_values, memory_values, time_values, cpu_usage_values, memory_usage_values

# Function to create dataframes
def create_dataframes(cpu_values, memory_values, time_values, cpu_usage_values, memory_usage_values):
    df_time = pd.DataFrame({'CPU': cpu_values, 'Memory': memory_values, 'TotalTime': time_values})
    df_cpu_usage = pd.DataFrame({'CPU': cpu_values, 'Memory': memory_values, 'CPUUsage': cpu_usage_values})
    df_memory_usage = pd.DataFrame({'CPU': cpu_values, 'Memory': memory_values, 'MemoryUsage': memory_usage_values})
    return df_time, df_cpu_usage, df_memory_usage

# Function to save heatmaps as PNG files
def save_heatmap(df_time, df_cpu_usage, df_memory_usage, output_file = 'heatmap.png'):
    df_time_pivot = df_time.pivot_table(index="CPU", columns="Memory", values="TotalTime")
    df_cpu_usage_pivot = df_cpu_usage.pivot_table(index="CPU", columns="Memory", values="CPUUsage")
    df_memory_usage_pivot = df_memory_usage.pivot_table(index="CPU", columns="Memory", values="MemoryUsage")

    plt.figure(figsize=(12, 6))

    plt.subplot(1, 3, 1)
    sns.heatmap(df_time_pivot, annot=True, cmap="coolwarm")
    plt.title('Total Time')

    plt.subplot(1, 3, 2)
    sns.heatmap(df_cpu_usage_pivot, annot=True, cmap="coolwarm")
    plt.title('CPU Usage')

    plt.subplot(1, 3, 3)
    sns.heatmap(df_memory_usage_pivot, annot=True, cmap="coolwarm")
    plt.title('Memory Usage')

    plt.tight_layout()
    plt.savefig(output_file)

# Main function to run the script
def main(file_pattern):
    input_file, output_file = select_file(file_pattern)
    data = load_data(input_file)
    cpu_values, memory_values, time_values, cpu_usage_values, memory_usage_values = process_data(data)
    df_time, df_cpu_usage, df_memory_usage = create_dataframes(cpu_values, memory_values, time_values, cpu_usage_values, memory_usage_values)
    save_heatmap(df_time, df_cpu_usage, df_memory_usage, output_file)
    print(f'Generated the values of {input_file} to {output_file}')

main('results/metrics_*.json')
