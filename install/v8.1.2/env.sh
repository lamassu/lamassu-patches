#!/usr/bin/env bash
set -e
    
OPTIONS_POSTGRES_PW=$(grep -oP '(?<="postgresql": ")[^"]*' /etc/lamassu/lamassu.json | sed -nr 's/.*:(.*)@.*/\1/p')
OPTIONS_HOSTNAME=$(grep -oP '(?<="hostname": ")[^"]*' /etc/lamassu/lamassu.json)

node /usr/local/lib/node_modules/lamassu-server/tools/build-prod-env.js --db-password $OPTIONS_POSTGRES_PW --hostname $OPTIONS_HOSTNAME

cp --symbolic-link /etc/lamassu/.env /usr/local/lib/node_modules/lamassu-server/.env

echo
echo "Done."
