#!/bin/bash
# Získáme počet selhání přímo ze systemd journalu pro službu ssh
FAILED=$(journalctl -u ssh | grep -c "Failed password")

echo "ssh_failed_logins_total $FAILED" > /var/lib/node_exporter/textfile_collector/ssh.prom
