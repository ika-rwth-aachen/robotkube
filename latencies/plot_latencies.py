#!/usr/bin/env python

import csv
import sys

import matplotlib.pyplot as plt


# parse input csv
data = []
input_file = sys.argv[1]
with open(input_file, "r") as f:
    reader = csv.reader(f)
    for row in reader:
        row_data = [int(ts) if len(ts) > 0 else None for ts in row]
        data.append(row_data)

# set missing timestamps to next available timestamp
for i, row_data in enumerate(data):
    for j, ts in enumerate(row_data):
        if ts is None and j > 0:
            row_data[j] = row_data[j-1]
            print(f"Warning: Missing timestamp {j} in measurement {i+1}")
    data[i] = row_data

# compute partial latencies
latencies = []
for experiment in data:
    experiment_latencies = []
    for i in range(len(experiment)-1):
        latency = experiment[i+1] - experiment[i]
        experiment_latencies.append(latency)
    latencies.append(experiment_latencies)

# average latencies over experiments
avg_latencies = [sum(col)/len(col) for col in zip(*latencies)]
print("Average latencies:")
for i, latency in enumerate(avg_latencies):
    print(f"{i} > {i+1}\t{latency:4.0f} ms")

# plot latencies
labels = [str(i) for i in range(11)]
for i in range(len(avg_latencies)):
    plt.barh(0, avg_latencies[i], left=sum(avg_latencies[:i]))
plt.show()
