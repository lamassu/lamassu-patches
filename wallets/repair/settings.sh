#!/bin/bash

echo
echo "Replacing original settings.json files..."

supervisorctl stop bitcoin litecoin &>/dev/null

curl -o /mnt/blockchains/bitcoin/settings.json https://raw.githubusercontent.com/lamassu/lamassu-patches/master/wallets/repair/orig/settings.json &>/dev/null
curl -o /mnt/blockchains/litecoin/settings.json https://raw.githubusercontent.com/lamassu/lamassu-patches/master/wallets/repair/orig/settings.json &>/dev/null

echo
echo "Restarting bitcoind and litecoind..."

supervisorctl start bitcoin litecoin &>/dev/null

echo
echo "Done."
echo
