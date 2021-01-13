#!/bin/bash
set -e

echo
echo "Adding mock-wallet option..."

curl -#o $(npm root -g)/lamassu-server/lib/new-admin/config/accounts.js https://raw.githubusercontent.com/lamassu/lamassu-patches/master/switches/admin/mock/accounts.js &>/dev/null
supervisorctl restart lamassu-admin-server &>/dev/null

echo
echo "Done! Now go to the 'Settings > Wallet' panel in your admin, edit a coin's wallet, and choose 'Mock'."
echo
