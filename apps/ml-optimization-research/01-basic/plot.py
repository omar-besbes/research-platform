import json
import pandas as pd
import seaborn as sns
import numpy as np
import matplotlib.pyplot as plt

# Load JSON data from file
with open('metrics.json') as f:
    data = json.load(f)

# Process data into a list of rows
rows = []
for item in data:
    cpu = item['config']['cpu']
    memory = item['config']['memory']
    metrics = item['metrics']
    rows.append([
        cpu,
        memory,
        metrics.get('totalTime', 'N/A'),
        metrics.get('totalCpuUsage', 'N/A'),
        metrics.get('totalMemoryUsage', 'N/A'),
        metrics.get('avgCpuUsage', 'N/A'),
        metrics.get('avgMemoryUsage', 'N/A')
    ])

# Create DataFrame
df = pd.DataFrame(rows, columns=['CPU', 'Memory', 'Total Time', 'Total CPU Usage', 'Total Memory Usage', 'Avg CPU Usage', 'Avg Memory Usage'])

# Convert 'CPU' and 'Memory' to numeric values
df['CPU'] = df['CPU'].str.replace('m', '', regex=False).astype(float)
df['Memory'] = df['Memory'].str.replace('gi', '', regex=False).astype(float)

# Replace 'N/A' with NaN for numeric columns
numeric_columns = ['Total Time', 'Total CPU Usage', 'Total Memory Usage', 'Avg CPU Usage', 'Avg Memory Usage']
df[numeric_columns] = df[numeric_columns].replace('N/A', np.nan).astype(float)

# Pivot table for heatmap
pivot_table = df.pivot(index='CPU', columns='Memory', values='Avg CPU Usage')

# Plot heatmap
plt.figure(figsize=(10, 8))
sns.heatmap(pivot_table, cmap='viridis', annot=True, fmt='.2f')
plt.title('Average CPU Usage Heatmap')
plt.xlabel('Memory (Gi)')
plt.ylabel('CPU (m)')

# Save plot to file
plt.savefig('heatmap.png')
