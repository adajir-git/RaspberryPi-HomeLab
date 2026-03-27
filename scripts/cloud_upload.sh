#!/bin/bash

# Cesty
LOCAL="/home/adajir/backup_dir/backups"
REMOTE="gdrive:Server_Backup"
METRICS_PATH="/var/lib/node_exporter/textfile_collector/backup_onedrive.prom"
LOG_FILE="/home/adajir/backup_dir/backup.log"

# 1. Nahrávání do cloudu
# Synchronizuje lokální složku do Server_Backup na OneDrive
nice -n 19 ionice -c2 -n7 rclone sync "$LOCAL" "$REMOTE" --exclude "full_ssd/**" --tpslimit 8

# Kontrola, zda rclone proběhl bez chyb (Exit kód 0)
if [ $? -eq 0 ]; then
    # 2. Zápis metriky pro Grafanu (pouze při úspěchu!)
    echo "backup_googledisk_last_success $(date +%s)" > "$METRICS_PATH"
    
    # 3. Zápis do logu
    echo "Cloudová synchronizace Google Disk úspěšná: $(date)" >> "$LOG_FILE"
else
    # 4. Zápis chyby (čas pro Grafanu se NEAKTUALIZUJE)
    echo "CHYBA: Cloudová synchronizace Google Disk selhala: $(date)" >> "$LOG_FILE"
fi
