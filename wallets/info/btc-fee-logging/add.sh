#!/bin/bash
set -e

echo
echo "Adding bitcoind fee logging..."

curl -#o $(npm root -g)/lamassu-server/lib/plugins/wallet/bitcoind/bitcoind.js https://raw.githubusercontent.com/lamassu/lamassu-patches/master/wallets/info/btc-fee-logging/bitcoind.js &>/dev/null

sleep 1s
supervisorctl restart lamassu-server &>/dev/null

echo
echo "Done!"
echo
