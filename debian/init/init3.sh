#!/usr/bin/env bash

# Import Enviroment Variables
set -a; source .env; set +a

# backup LMDS docker-compose.yml & transfer minimal unifi docker-compose.yml
mv ~/LMDS/docker-compose.yml ~/LMDS/docker-compose.yml.bak
cp ~/init/docker-compose.yml ~/LMDS/docker-compose.yml
docker-compose up -d