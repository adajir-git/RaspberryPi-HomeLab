#!/bin/bash

# --- Configuration ---
# Adjust the path if your Minecraft world is stored elsewhere
WORLD_PATH="/mnt/data/minecraft/world"
METRICS_FILE="/var/lib/node_exporter/textfile_collector/world_size.prom"

# --- Storage Monitoring ---

# Measure the size of the world folder in bytes.
# -s: summary, -b: apparent size in bytes.
WORLD_SIZE_BYTES=$(du -sb "$WORLD_PATH" | cut -f1)

# --- Export Metrics ---
echo "minecraft_world_size_bytes $WORLD_SIZE_BYTES" > "$METRICS_FILE"
