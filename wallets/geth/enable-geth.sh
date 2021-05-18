#!/usr/bin/env bash
set -e

bold=$(tput bold)
normal=$(tput sgr0)
ETHCONF=/etc/supervisor/conf.d/ethereum.conf

echo
echo "Enabling Geth option..."

curl -#o $(npm root -g)/lamassu-server/lib/blockchain/common.js https://raw.githubusercontent.com/lamassu/lamassu-server/ecd4a05d90e6e326b4b1ab4bd49ed6ca11984a4b/lib/blockchain/common.js &>/dev/null

curl -#o $(npm root -g)/lamassu-server/lib/blockchain/ethereum.js https://raw.githubusercontent.com/lamassu/lamassu-server/ecd4a05d90e6e326b4b1ab4bd49ed6ca11984a4b/lib/blockchain/ethereum.js &>/dev/null

curl -#o $(npm root -g)/lamassu-server/lib/blockchain/install.js https://raw.githubusercontent.com/lamassu/lamassu-server/ecd4a05d90e6e326b4b1ab4bd49ed6ca11984a4b/lib/blockchain/install.js &>/dev/null

curl -#o $(npm root -g)/lamassu-server/lib/new-admin/config/accounts.js https://raw.githubusercontent.com/lamassu/lamassu-server/ecd4a05d90e6e326b4b1ab4bd49ed6ca11984a4b/lib/new-admin/config/accounts.js &>/dev/null

curl -#o $(npm root -g)/lamassu-server/lib/plugins/wallet/geth/base.js https://raw.githubusercontent.com/lamassu/lamassu-server/ecd4a05d90e6e326b4b1ab4bd49ed6ca11984a4b/lib/plugins/wallet/geth/base.js &>/dev/null

if test -f "$ETHCONF"; then
    curl -#o "$ETHCONF" https://raw.githubusercontent.com/lamassu/lamassu-patches/master/wallets/geth/ethereum.conf &>/dev/null
fi

supervisorctl restart lamassu-server lamassu-admin-server &>/dev/null

echo
echo "Done."
echo
echo "Now install Geth by running the command ${bold}lamassu-coins${normal} and selecting ${bold}Ethereum${normal}."
echo
echo "Afterward, navigate to 'Settings > Wallet' in your admin, and for Ethereum select 'geth' instead of 'Infura' as the wallet option."
echo
