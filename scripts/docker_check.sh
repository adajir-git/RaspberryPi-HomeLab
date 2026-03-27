#!/bin/bash
RUNNING=$(docker ps -q | wc -l)
TOTAL=$(docker ps -a -q | wc -l)

echo "docker_containers_running $RUNNING" > /var/lib/node_exporter/textfile_collector/docker.prom
echo "docker_containers_total $TOTAL" >> /var/lib/node_exporter/textfile_collector/docker.prom
