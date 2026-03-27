#!/bin/bash

# 1. Stáhne seznam z internetu (potichu)
apt-get update -qq

# 2. Vytáhne počet updatů (pokud nic nenajde, vrátí 0)
UPDATES=$(apt-get -s upgrade | grep -P -o '^[0-9]+(?= upgraded)' || echo "0")

# 3. Zjistí, jestli systém vyžaduje restart (1 = Ano, 0 = Ne)
if [ -f /var/run/reboot-required ]; then
    REBOOT_REQ=1
else
    REBOOT_REQ=0
fi

# 4. Atomický zápis obou metrik pro Grafanu
cat <<EOF > /var/lib/node_exporter/textfile_collector/apt_upgrades.prom
apt_upgrades_pending $UPDATES
system_reboot_required $REBOOT_REQ
EOF
