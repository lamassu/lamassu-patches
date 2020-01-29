#!/usr/bin/env bash
set -e

echo
echo "Adding GBP and CAD markets to Kraken trader..."
curl -#o $(npm root -g)/lamassu-server/lib/plugins/exchange/kraken/kraken.js https://raw.githubusercontent.com/lamassu/lamassu-patches/master/switches/kraken/kraken-gbp-cad.js &>/dev/null

echo
echo "Adding GBP and CAD pairs to Kraken..."
curl -#o $(npm root -g)/lamassu-server/lib/plugins/common/kraken.js https://raw.githubusercontent.com/lamassu/lamassu-patches/master/switches/kraken/kraken-common-gbp-cad.js &>/dev/null

echo
echo "Restarting lamassu-server..."
supervisorctl restart lamassu-server &>/dev/null
echo
echo "Update complete."
echo
