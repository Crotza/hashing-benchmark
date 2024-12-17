import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import os

# Create a 'plots' directory if it doesn't exist
PLOT_DIR = "plots"
os.makedirs(PLOT_DIR, exist_ok=True)

# Load the CSV files
sequential_data = pd.read_csv("logs/master_sequential_metrics.csv")
parallel_data = pd.read_csv("logs/master_parallel_metrics.csv")

# Combine both datasets with an additional column for comparison
sequential_data['Execution Mode'] = 'Sequential'
parallel_data['Execution Mode'] = 'Parallel'
data = pd.concat([sequential_data, parallel_data], ignore_index=True)

# Define colors for each execution mode
colors = {'Sequential': 'red', 'Parallel': 'green'}

# Define bar width and positions
algorithms = data['Algorithm'].unique()
x = np.arange(len(algorithms))
bar_width = 0.35  # Adjust the width for spacing

# Plot: Total Time per Algorithm
plt.figure(figsize=(10, 6))
for idx, mode in enumerate(data['Execution Mode'].unique()):
    group = data[data['Execution Mode'] == mode]
    plt.bar(x + (idx * bar_width), group['Total Time (ms)'], 
            width=bar_width, label=mode, color=colors[mode])
plt.title('Total Time Comparison (Sequential vs Parallel)')
plt.xlabel('Algorithm')
plt.ylabel('Total Time (ms)')
plt.xticks(x + bar_width / 2, algorithms, rotation=45)
plt.legend()
plt.tight_layout()
plt.savefig(f"{PLOT_DIR}/total_time_comparison.png")
print(f"     📊 Total Time Comparison (Sequential vs Parallel) plot saved. Check '{PLOT_DIR}/total_time_comparison.png' to see it.")

# Plot: Throughput per Algorithm
plt.figure(figsize=(10, 6))
for idx, mode in enumerate(data['Execution Mode'].unique()):
    group = data[data['Execution Mode'] == mode]
    plt.bar(x + (idx * bar_width), group['Throughput (assets/sec)'], 
            width=bar_width, label=mode, color=colors[mode])
plt.title('Throughput Comparison (Sequential vs Parallel)')
plt.xlabel('Algorithm')
plt.ylabel('Throughput (assets/sec)')
plt.xticks(x + bar_width / 2, algorithms, rotation=45) 
plt.legend()
plt.tight_layout()
plt.savefig(f"{PLOT_DIR}/throughput_comparison.png")
print(f"     📊 Throughput Comparison (Sequential vs Parallel) plot saved. Check '{PLOT_DIR}/throughput_comparison.png' to see it.")

# Add more plots for Avg Latency, CPU, Memory, etc.
metrics = [
    ('Avg CPU (%)', 'Avg CPU (%) Comparison'),
    ('Peak CPU (%)', 'Peak CPU (%) Comparison'),
    ('Avg Latency (ms)', 'Avg Latency (ms) Comparison'),
    ('Max Latency (ms)', 'Max Latency (ms) Comparison'),
    ('Min Latency (ms)', 'Min Latency (ms) Comparison'),
    ('Peak Mem (%)', 'Peak Mem (%) Comparison')
]

for metric, title in metrics:
    plt.figure(figsize=(10, 6))
    for idx, mode in enumerate(data['Execution Mode'].unique()):
        group = data[data['Execution Mode'] == mode]
        plt.bar(x + (idx * bar_width), group[metric], 
                width=bar_width, label=mode, color=colors[mode])
    plt.title(f"{title} (Sequential vs Parallel)")
    plt.xlabel('Algorithm')
    plt.ylabel(metric)
    plt.xticks(x + bar_width / 2, algorithms, rotation=45)
    plt.legend()
    plt.tight_layout()
    filename = f"{PLOT_DIR}/{title.lower().replace(' ', '_')}.png"
    plt.savefig(filename)
    print(f"     📊 {title} (Sequential vs Parallel) plot saved. Check '{filename}' to see it.")

# Relative Improvement Plots
throughput_diff = ((parallel_data['Throughput (assets/sec)'].values - sequential_data['Throughput (assets/sec)'].values) / sequential_data['Throughput (assets/sec)'].values) * 100
total_time_diff = ((sequential_data['Total Time (ms)'].values - parallel_data['Total Time (ms)'].values) / sequential_data['Total Time (ms)'].values) * 100

# Relative Throughput Improvement
plt.figure(figsize=(10, 6))
plt.bar(algorithms, throughput_diff, color='orange')
plt.title('Relative Improvement in Throughput (Sequential → Parallel)')
plt.xlabel('Algorithm')
plt.ylabel('Improvement (%)')
plt.tight_layout()
plt.savefig(f"{PLOT_DIR}/relative_throughput_improvement.png")
print(f"     📊 Relative Improvement in Throughput (Sequential → Parallel) plot saved. Check '{PLOT_DIR}/relative_throughput_improvement.png' to see it.")

# Relative Total Time Improvement
plt.figure(figsize=(10, 6))
plt.bar(algorithms, total_time_diff, color='purple')
plt.title('Relative Improvement in Total Time (Sequential → Parallel)')
plt.xlabel('Algorithm')
plt.ylabel('Improvement (%)')
plt.tight_layout()
plt.savefig(f"{PLOT_DIR}/relative_total_time_improvement.png")
print(f"     📊 Relative Improvement in Total Time (Sequential → Parallel) plot saved. Check '{PLOT_DIR}/relative_total_time_improvement.png' to see it.")

print(f"     ✅ All plots have been saved. Check '{PLOT_DIR}' for all plots.")
