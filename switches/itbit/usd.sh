#!/usr/bin/env bash
set -e

echo
echo "Updating itBit plugin to default to USD trading..."
curl -#o $(npm root -g)/lamassu-server/lib/plugins/common/itbit.js https://raw.githubusercontent.com/lamassu/lamassu-patches/master/switches/itbit/itbit.js &>/dev/null

echo
echo "Restarting lamassu-server..."
supervisorctl restart lamassu-server &>/dev/null
echo
echo "Update complete."
echo
