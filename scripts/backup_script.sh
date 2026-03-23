#!/bin/bash

# --- Configuration ---
SOURCE_DIR="/mnt/data/"
BACKUP_DEST="/home/adajir/backup_dir/backups/full_ssd"
METRICS_FILE="/var/lib/node_exporter/textfile_collector/backup_sd.prom"
LOG_FILE="/home/adajir/backup_dir/backup.log"

# --- Pre-flight Check ---
# Ensure the external SSD is actually mounted to prevent filling up the SD card/root partition
if ! mountpoint -q /mnt/data; then
    echo "ERROR: SSD disk /mnt/data is not mounted! Aborting backup." >> "$LOG_FILE"
    exit 1
fi

# --- Execution ---

# 1. Sync data from SSD to local storage
# -a: archive mode, -v: verbose, --delete: remove files at destination that were deleted at source
rsync -av --delete "$SOURCE_DIR" "$BACKUP_DEST"

# 2. Reset ownership to the primary user
chown -R adajir:adajir "$BACKUP_DEST"

# 3. Create a compressed daily archive
# We use 'nice' and 'ionice' to lower CPU and Disk I/O priority, 
# ensuring the system (and Minecraft) remains responsive during compression.
ARCHIVE_NAME="/home/adajir/backup_dir/backups/archive_$(date +%Y-%m-%d).tar.gz"

nice -n 19 ionice -c2 -n7 tar -czf "$ARCHIVE_NAME" "$BACKUP_DEST"

# 4. Success/Failure Handling
if [ $? -eq 0 ]; then
    # SUCCESS: Compression finished correctly
    
    # Retention policy: Delete archives older than 7 days to save space
    find /home/adajir/backup_dir/backups/ -name "archive_*.tar.gz" -mtime +7 -delete
    
    # Export Unix timestamp for Prometheus/Grafana monitoring
    echo "backup_sd_last_success $(date +%s)" > "$METRICS_FILE"
    
    # Log successful operation
    echo "Local backup SSD -> SD successful: $(date)" >> "$LOG_FILE"

else
    # FAILURE: Something went wrong (e.g., Disk Full)
    
    # Log error - Note: Metrics file is NOT updated so Grafana can trigger an alert
    echo "ERROR: Local backup failed during compression: $(date)" >> "$LOG_FILE"
fi
