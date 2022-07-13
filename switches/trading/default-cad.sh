#!/usr/bin/env bash
set -e

echo
echo "Updating trading plugin to default to CAD..."

supervisorctl stop lamassu-server &>/dev/null
sed -i "s/'EUR'/'CAD'/g" $(npm root -g)/lamassu-server/lib/plugins/common/ccxt.js &>/dev/null
supervisorctl start lamassu-server &>/dev/null

echo
echo "Done."
echo
echo "Note: If you update to a new server release, this script will need to be run again (until a market selector is included within the admin)."
echo
