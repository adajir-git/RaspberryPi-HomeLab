#!/bin/bash

# --- Configuration ---
# Path where node_exporter's textfile collector looks for custom metrics
METRICS_FILE="/var/lib/node_exporter/textfile_collector/apt_upgrades.prom"

# 1. Update package repositories
# -qq: Quite mode (no output) to keep the logs clean
apt-get update -qq

# 2. Check for pending updates
# We use 'apt-get -s upgrade' to simulate an upgrade without actually installing anything.
# Then we grep the output for the number of packages marked as 'upgraded'.
# If the command fails or returns no number, we default to 0.
UPDATES_COUNT=$(apt-get -s upgrade | grep -P -o '^[0-9]+(?= upgraded)' || echo "0")

# 3. Check if a system reboot is required
# On Debian/Ubuntu based systems, the presence of this file indicates 
# that a kernel or system library update requires a reboot.
if [ -f /var/run/reboot-required ]; then
    REBOOT_REQUIRED=1
else
    REBOOT_REQUIRED=0
fi

# 4. Export metrics for Prometheus
# Using a heredoc (EOF) to write multiple metrics at once.
# Note: We overwrite the file to ensure the data is always fresh.
cat <<EOF > "$METRICS_FILE"
apt_upgrades_pending $UPDATES_COUNT
system_reboot_required $REBOOT_REQUIRED
EOF
