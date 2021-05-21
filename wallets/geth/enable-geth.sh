#!/usr/bin/env bash
set -e

bold=$(tput bold)
normal=$(tput sgr0)
ETHCONF=/etc/supervisor/conf.d/ethereum.conf
NEWADMIN=$(npm root -g)/lamassu-server/lib/new-admin/config/accounts.js

echo
echo "Enabling Geth option..."

curl -#o $(npm root -g)/lamassu-server/lib/blockchain/common.js https://raw.githubusercontent.com/lamassu/lamassu-server/release-7.5.0/lib/blockchain/common.js &>/dev/null
curl -#o $(npm root -g)/lamassu-server/lib/blockchain/ethereum.js https://raw.githubusercontent.com/lamassu/lamassu-server/release-7.5.0/lib/blockchain/ethereum.js &>/dev/null
curl -#o $(npm root -g)/lamassu-server/lib/blockchain/install.js https://raw.githubusercontent.com/lamassu/lamassu-server/release-7.5.0/lib/blockchain/install.js &>/dev/null
curl -#o $(npm root -g)/lamassu-server/lib/plugins/wallet/geth/base.js https://raw.githubusercontent.com/lamassu/lamassu-server/release-7.5.0/lib/plugins/wallet/geth/base.js &>/dev/null

## Don't fail if v7.4
if test -f "$NEWADMIN"; then
    curl -#o "$NEWADMIN" https://raw.githubusercontent.com/lamassu/lamassu-server/release-7.5.0/lib/new-admin/config/accounts.js &>/dev/null
fi

## Ensure any existing config is set to light
if test -f "$ETHCONF"; then
    curl -#o "$ETHCONF" https://raw.githubusercontent.com/lamassu/lamassu-patches/master/wallets/geth/ethereum.conf &>/dev/null
    supervisorctl reread &>/dev/null
fi

supervisorctl restart lamassu-server lamassu-admin-server &>/dev/null

echo
echo "Done."
echo
echo "Now install Geth by running the command ${bold}lamassu-coins${normal} and selecting ${bold}Ethereum${normal}."
echo
echo "Afterward, navigate to 'Settings > Wallet' in your admin, and for Ethereum select 'geth' instead of 'Infura' as the wallet option."
echo
