#!/usr/bin/env bash

echo
echo "Patching Monero wallet code..."

supervisorctl stop lamassu-server monero monero-wallet &>/dev/null

curl -o $(npm root -g)/lamassu-server/lib/plugins/wallet/monerod/monerod.js https://raw.githubusercontent.com/lamassu/lamassu-server/521afb0c4e0cf0124c02fc78f89cf6d007babdcf/lib/plugins/wallet/monerod/monerod.js

supervisorctl start lamassu-server monero monero-wallet &>/dev/null

echo
echo "Done!"
echo
