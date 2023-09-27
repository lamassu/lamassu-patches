#!/usr/bin/env bash
set -e

echo
echo "Adding GBP and CAD markets to Kraken..."
curl -#o $(npm root -g)/lamassu-server/lib/plugins/exchange/kraken.js https://raw.githubusercontent.com/lamassu/lamassu-patches/master/switches/kraken/kraken-gbp-cad.js &>/dev/null

echo
echo "Restarting lamassu-server..."
supervisorctl restart lamassu-server &>/dev/null
echo
echo "Update complete."
echo
