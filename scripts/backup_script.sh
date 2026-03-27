#!/bin/bash

# Cesty
SOURCE="/mnt/data/"
DEST="/home/adajir/backup_dir/backups/full_ssd"
METRICS_PATH="/var/lib/node_exporter/textfile_collector/backup_sd.prom"
LOG_FILE="/home/adajir/backup_dir/backup.log"

if ! mountpoint -q /mnt/data; then
    echo "CHYBA: SSD disk /mnt/data neni pripojen! Koncim." >> /home/adajir/backup_dir/backup.log
    exit 1
fi

# 1. Samotný backup (smaže na cíli to, co zmizelo na zdroji)
rsync -av --delete "$SOURCE" "$DEST"

# 2. Vrácení práv uživateli adajir
chown -R adajir:adajir "$DEST"

# 3. Vytvoření komprimovaného archivu aktuálního dne
nice -n 19 ionice -c2 -n7 tar -czf /home/adajir/backup_dir/backups/archive_$(date +%Y-%m-%d).tar.gz "$DEST"

# 4. KLÍČOVÝ KROK: Kontrola úspěchu u nejnáročnější operace (tar)
if [ $? -eq 0 ]; then
    # -- Pokud balení proběhlo bez chyby --
    
    # Smaže archivy starší než 7 dní
    find /home/adajir/backup_dir/backups/ -name "archive_*.tar.gz" -mtime +7 -delete
    
    # Zápis metriky pro Grafanu
    echo "backup_sd_last_success $(date +%s)" > "$METRICS_PATH"
    
    # Zápis do logu (úspěch)
    echo "Lokální záloha SSD -> SD úspěšná: $(date)" >> "$LOG_FILE"

else
    # -- Pokud došlo k chybě (např. plný disk) --
    
    # Zápis do logu (selhání)
    echo "CHYBA: Lokální záloha na SD kartu selhala při balení: $(date)" >> "$LOG_FILE"
fi
