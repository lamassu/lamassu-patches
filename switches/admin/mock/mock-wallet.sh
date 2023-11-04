#!/bin/bash
set -e

sed -i "s/{ code: 'mock-wallet', display: 'Mock (Caution!)', class: WALLET, cryptos: ALL_CRYPTOS, dev: true },/{ code: 'mock-wallet', display: 'Mock (Caution!)', class: WALLET, cryptos: ALL_CRYPTOS },/g" $(npm -g root)/lamassu-server/lib/new-admin/config/accounts.js

supervisorctl restart lamassu-server lamassu-admin-server &>/dev/null

echo
echo "Mock wallet option enabled. Choose 'Mock wallet' in the admin's 'Settings > Wallets' panel. Use with caution!"
echo
