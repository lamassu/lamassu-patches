#!/usr/bin/env bash

supervisorctl stop lamassu-server lamassu-admin-server &>/dev/null

curl -o $(npm root -g)/lamassu-server/lib/plugins/wallet/geth/base.js https://raw.githubusercontent.com/lamassu/lamassu-patches/master/hotfix/usdt-cashout/base.js &>/dev/null

sleep 2s
supervisorctl start lamassu-server lamassu-admin-server &>/dev/null

echo
echo 'Done!'
echo
