#!/bin/bash

# --- Configuration ---
# Path for node_exporter's textfile collector
METRICS_FILE="/var/lib/node_exporter/textfile_collector/rpi_hw.prom"

# --- Hardware Monitoring ---

# 1. Get Throttled Status
# vcgencmd returns a hex value (e.g., throttled=0x50000). 
# This bitmask represents under-voltage, overheating, and frequency capping.
# Bit 0: Under-voltage detected | Bit 1: Arm frequency capped | Bit 2: Currently throttled
# Bits 16-19: Same events occurred since last boot.
HEX_STATUS=$(vcgencmd get_throttled | cut -d= -f2)

# Convert hex to decimal for easier processing in Prometheus/Grafana
DEC_STATUS=$(printf "%d" "$HEX_STATUS")

# 2. Get CPU Temperature
# Output is usually 'temp=45.5'C', so we strip the 'temp=' and ''C' parts.
CPU_TEMP=$(vcgencmd measure_temp | cut -d= -f2 | tr -d "'C")

# --- Export Metrics ---

# Write metrics to the .prom file
# Note: Using '>' for the first line to overwrite/clear the file, '>>' to append.
echo "rpi_throttled_status $DEC_STATUS" > "$METRICS_FILE"
echo "rpi_cpu_temp_vcgen $CPU_TEMP" >> "$METRICS_FILE"
