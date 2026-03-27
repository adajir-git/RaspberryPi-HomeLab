#!/bin/bash

# Změří velikost složek world v bajtech
SIZE=$(du -sb /mnt/data/minecraft/world | cut -f1)
SIZE_nether=$(du -sb /mnt/data/minecraft/world_nether | cut -f1)
SIZE_end=$(du -sb /mnt/data/minecraft/world_the_end | cut -f1)

# Sečte velikosti dohromady
FULL_SIZE=$(($SIZE + $SIZE_nether + $SIZE_end))

# Zapíše výsledek do Prometheus souboru
echo "minecraft_world_size_bytes $FULL_SIZE" > /var/lib/node_exporter/textfile_collector/world_size.prom
