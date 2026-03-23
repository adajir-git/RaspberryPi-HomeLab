#!/bin/bash

# --- Configuration ---
LOCAL_BACKUP_DIR="/home/adajir/backup_dir/backups"
REMOTE_DESTINATION="gdrive:Server_Backup"
METRICS_FILE="/var/lib/node_exporter/textfile_collector/backup_cloud.prom"
LOG_FILE="/home/adajir/backup_dir/backup.log"

# --- Cloud Synchronization ---

# We use 'rclone sync' to make the remote match the local directory.
# Priority management:
# - nice -n 19: Lowest CPU priority.
# - ionice -c2 -n7: Lowest disk I/O priority (best-effort).
#
# Flags:
# --exclude "full_ssd/**": We only want to upload compressed archives (.tar.gz), 
#                         not the raw uncompressed data.
# --tpslimit 8: Limits transactions per second to avoid Google Drive API rate limiting.
nice -n 19 ionice -c2 -n7 rclone sync "$LOCAL_BACKUP_DIR" "$REMOTE_DESTINATION" \
    --exclude "full_ssd/**" \
    --tpslimit 8

# --- Success/Failure Handling ---

if [ $? -eq 0 ]; then
    # SUCCESS: Cloud sync completed without errors
    
    # Update Prometheus metric with current Unix timestamp
    echo "backup_cloud_last_success $(date +%s)" > "$METRICS_FILE"
    
    # Log the successful sync
    echo "Cloud synchronization (Google Drive) successful: $(date)" >> "$LOG_FILE"
else
    # FAILURE: Something went wrong with the upload
    
    # Log the error. Metrics file is NOT updated, which will trigger a Grafana alert.
    echo "ERROR: Cloud synchronization (Google Drive) failed: $(date)" >> "$LOG_FILE"
fi
