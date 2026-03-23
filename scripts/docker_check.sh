#!/bin/bash

# --- Configuration ---
# Path for node_exporter's textfile collector
METRICS_FILE="/var/lib/node_exporter/textfile_collector/docker.prom"

# --- Execution ---

# 1. Count running containers
# 'docker ps -q' returns only the IDs of running containers.
# 'wc -l' counts the number of lines (i.e., the number of containers).
RUNNING_CONTAINERS=$(docker ps -q | wc -l)

# 2. Count total containers
# '-a' flag includes all containers (running, exited, or crashed).
TOTAL_CONTAINERS=$(docker ps -a -q | wc -l)

# --- Export Metrics ---

# Write the metrics to the Prometheus file.
# We overwrite the file with the first line (>) and append the second (>>).
echo "docker_containers_running $RUNNING_CONTAINERS" > "$METRICS_FILE"
echo "docker_containers_total $TOTAL_CONTAINERS" >> "$METRICS_FILE"
