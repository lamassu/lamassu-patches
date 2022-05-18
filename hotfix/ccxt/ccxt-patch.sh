#!/usr/bin/env bash
set -e

echo
echo "Patching to default to the EUR market..."
echo

cd $(npm root -g)/lamassu-server/lib/plugins/common/

curl -#o ccxt.js https://raw.githubusercontent.com/lamassu/lamassu-patches/master/hotfix/ccxt/ccxt.js &>/dev/null

sleep 2s
supervisorctl restart lamassu-server lamassu-admin-server &>/dev/null

echo "Trader file patched."
echo
