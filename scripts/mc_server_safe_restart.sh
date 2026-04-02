#!/bin/bash
# Název tvého kontejneru v Portaineru je mc-server
CONTAINER="mc-server"

# 1. Varování minutu předem
docker exec $CONTAINER rcon-cli say [UDRZBA] Server se za 60 sekund restartuje!
sleep 30

# 2. Varování 30 sekund předem
docker exec $CONTAINER rcon-cli say [UDRZBA] Restart za 30 sekund. Prosim, najdete si bezpecne misto!
sleep 20

# 3. Poslední odpočet
docker exec $CONTAINER rcon-cli say [UDRZBA] Restart za 10 sekund...
sleep 10

# 4. Bezpečné uložení a vypnutí
docker exec $CONTAINER rcon-cli save-all
docker exec $CONTAINER rcon-cli stop
