import json
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import numpy as np
import glob

def load_data(file_pattern):
    # Aggregate values from multiple JSON files
    data = []
    for file in glob.glob(file_pattern):
        with open(file) as f:
            data.extend(json.load(f))
    return data

def parse_data(data):
    metrics_dict = {}
    for entry in data:
        try:
            cpu = float(entry["config"]["cpu"].replace('m', '')) / 1000  # Convert millicores to cores
            memory = float(entry["config"]["memory"].replace('gi', ''))
            time = int(entry["metrics"]["totalTime"]) / 1000 # Convert milliseconds to seconds
            cpu_usage = float(entry["metrics"]["totalCpuUsage"])
            memory_usage = int(entry["metrics"]["totalMemoryUsage"]) / 1000 / 1000 / 1000 # Convert bytes to gigabytes
            
            key = (cpu, memory)
            if key not in metrics_dict:
                metrics_dict[key] = {
                    "TotalTime": [],
                    "CPUUsage": [],
                    "MemoryUsage": []
                }
            metrics_dict[key]["TotalTime"].append(time)
            metrics_dict[key]["CPUUsage"].append(cpu_usage)
            metrics_dict[key]["MemoryUsage"].append(memory_usage)
        except Exception as e:
            print(f"Error parsing entry: {e}")
    return metrics_dict

def compute_median(metrics_dict):
    median_metrics = {"CPU": [], "Memory": [], "TotalTime": [], "CPUUsage": [], "MemoryUsage": []}
    
    for (cpu, memory), metrics in metrics_dict.items():
        median_metrics["CPU"].append(cpu)
        median_metrics["Memory"].append(memory)
        median_metrics["TotalTime"].append(np.median(metrics["TotalTime"]))
        median_metrics["CPUUsage"].append(np.median(metrics["CPUUsage"]))
        median_metrics["MemoryUsage"].append(np.median(metrics["MemoryUsage"]))

    return pd.DataFrame(median_metrics)

def compute_mean(metrics_dict):
    mean_metrics = {"CPU": [], "Memory": [], "TotalTime": [], "CPUUsage": [], "MemoryUsage": []}
    
    for (cpu, memory), metrics in metrics_dict.items():
        mean_metrics["CPU"].append(cpu)
        mean_metrics["Memory"].append(memory)
        mean_metrics["TotalTime"].append(np.mean(metrics["TotalTime"]))
        mean_metrics["CPUUsage"].append(np.mean(metrics["CPUUsage"]))
        mean_metrics["MemoryUsage"].append(np.mean(metrics["MemoryUsage"]))

    return pd.DataFrame(mean_metrics)

def plot_heatmaps(df_median, df_mean):
    # Pivot data for heatmaps
    df_time_median_pivot = df_median.pivot_table("TotalTime", "CPU", "Memory")
    df_cpu_usage_median_pivot = df_median.pivot_table("CPUUsage", "CPU", "Memory")
    df_memory_usage_median_pivot = df_median.pivot_table("MemoryUsage", "CPU", "Memory")
    
    df_time_mean_pivot = df_mean.pivot_table("TotalTime", "CPU", "Memory")
    df_cpu_usage_mean_pivot = df_mean.pivot_table("CPUUsage", "CPU", "Memory")
    df_memory_usage_mean_pivot = df_mean.pivot_table("MemoryUsage", "CPU", "Memory")

    # Create subplots for both median and mean
    plt.figure(figsize=(18, 12))

    # Median heatmaps
    plt.subplot(2, 3, 1)
    sns.heatmap(df_time_median_pivot, annot=True, cmap="coolwarm")
    plt.gca().invert_yaxis()
    plt.title('Median - Total Time')

    plt.subplot(2, 3, 2)
    sns.heatmap(df_cpu_usage_median_pivot, annot=True, cmap="coolwarm")
    plt.gca().invert_yaxis()
    plt.title('Median - CPU Usage')

    plt.subplot(2, 3, 3)
    sns.heatmap(df_memory_usage_median_pivot, annot=True, cmap="coolwarm")
    plt.gca().invert_yaxis()
    plt.title('Median - Memory Usage')

    # Mean heatmaps
    plt.subplot(2, 3, 4)
    sns.heatmap(df_time_mean_pivot, annot=True, cmap="coolwarm")
    plt.gca().invert_yaxis()
    plt.title('Mean - Total Time')

    plt.subplot(2, 3, 5)
    sns.heatmap(df_cpu_usage_mean_pivot, annot=True, cmap="coolwarm")
    plt.gca().invert_yaxis()
    plt.title('Mean - CPU Usage')

    plt.subplot(2, 3, 6)
    sns.heatmap(df_memory_usage_mean_pivot, annot=True, cmap="coolwarm")
    plt.gca().invert_yaxis()
    plt.title('Mean - Memory Usage')

    plt.tight_layout()
    plt.savefig('combined_heatmap.png')

# Main function to load, process, and plot the heatmaps
def main(file_pattern):
    data = load_data(file_pattern)
    metrics_dict = parse_data(data)

    df_median = compute_median(metrics_dict)
    df_mean = compute_mean(metrics_dict)

    plot_heatmaps(df_median, df_mean)

main('results/metrics_*.json')
