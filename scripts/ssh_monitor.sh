#!/bin/bash

# --- Configuration ---
METRICS_FILE="/var/lib/node_exporter/textfile_collector/ssh.prom"

# --- Security Audit ---

# Count failed password attempts directly from the systemd journal for the ssh service.
# This helps detect brute-force attack attempts.
FAILED_LOGINS=$(journalctl -u ssh | grep -c "Failed password")

# --- Export Metrics ---
echo "ssh_failed_logins_total $FAILED_LOGINS" > "$METRICS_FILE"
