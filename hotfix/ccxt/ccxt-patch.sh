#!/usr/bin/env bash
set -e

echo

echo "Patching to default to the EUR market..."

cd $(npm root -g)/lamassu-server/lib/plugins/common/
curl -#o ccxt.js https://raw.githubusercontent.com/lamassu/lamassu-patches/master/hotfix/ccxt/ccxt.js &>/dev/null
echo

echo "Patching to increase Kraken API request nonce precision..."

cd $(npm root -g)/lamassu-server/lib/plugins/exchange/
curl -#o kraken.js https://raw.githubusercontent.com/lamassu/lamassu-patches/master/hotfix/ccxt/kraken.js &>/dev/null
echo

sleep 2s
supervisorctl restart lamassu-server lamassu-admin-server &>/dev/null

echo "Done."
echo
