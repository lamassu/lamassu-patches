#!/bin/bash
set -e

echo
echo "Updating dashd and instructing it to reindex the wallet."
echo
echo "This may take a minute..."

curl -sS https://raw.githubusercontent.com/lamassu/lamassu-patches/master/wallets/update/dash.sh | bash &>/dev/null

supervisorctl stop dash &>/dev/null

curl -#o /etc/supervisor/conf.d/dash.conf https://raw.githubusercontent.com/lamassu/lamassu-patches/master/wallets/reindex/dash/dash-reindex.conf &>/dev/null

supervisorctl update dash &>/dev/null

sleep 5s

curl -#o /etc/supervisor/conf.d/dash.conf https://raw.githubusercontent.com/lamassu/lamassu-patches/master/wallets/reindex/dash/dash.conf &>/dev/null

sleep 10s

supervisorctl update dash &>/dev/null

echo
echo "Done. Your latest wallet balance will be displayed after the blockchain has fully reindexed."
echo
echo "This may take some time. Use the KB article 'Checking wallet synchronization' for current status."
echo
