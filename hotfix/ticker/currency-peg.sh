#!/usr/bin/env bash

echo
echo "Adding NAD : ZAR currency peg..."

supervisorctl stop lamassu-server lamassu-admin-server &>/dev/null

curl -o $(npm root -g)/lamassu-server/lib/ticker.js https://raw.githubusercontent.com/lamassu/lamassu-server/cc0d5e01c429659880fef9d205e6cc449478a910/lib/ticker.js &>/dev/null

supervisorctl start lamassu-server lamassu-admin-server &>/dev/null

echo
echo "Done!"
echo
