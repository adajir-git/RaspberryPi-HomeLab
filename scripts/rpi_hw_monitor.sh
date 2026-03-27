#!/bin/bash
# Načte hexu, ale do proměnné uloží jen číslo (printf %d převede 0x0 na 0)
HEX_VAL=$(vcgencmd get_throttled | cut -d= -f2)
DEC_VAL=$(printf "%d" "$HEX_VAL")

# Teplota bez zbytečných znaků
TEMP=$(vcgencmd measure_temp | cut -d= -f2 | tr -d "'C")

# Zápis do souboru - čistě a bezpečně
echo "rpi_throttled_status $DEC_VAL" > /var/lib/node_exporter/textfile_collector/rpi_hw.prom
echo "rpi_cpu_temp_vcgen $TEMP" >> /var/lib/node_exporter/textfile_collector/rpi_hw.prom
