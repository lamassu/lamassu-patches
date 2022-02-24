#!/usr/bin/env bash
set -e

echo
echo "Updating Bitstamp plugin to use USD..."
curl -#o $(npm root -g)/lamassu-server/lib/plugins/exchange/bitstamp/bitstamp.js https://raw.githubusercontent.com/lamassu/lamassu-patches/master/switches/bitstamp/usd.js &>/dev/null

echo
echo "Restarting lamassu-server..."
supervisorctl restart lamassu-server &>/dev/null
echo
echo "Update complete."
echo
