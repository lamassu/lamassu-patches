#!/bin/bash
set -e

echo
echo "Updating dashd and instructing it to reindex the wallet."
echo
echo "This may take a minute..."

supervisorctl stop dash &>/dev/null

curl -#Lo /tmp/dash.tar.gz https://github.com/dashpay/dash/releases/download/v0.17.0.3/dashcore-0.17.0.3-x86_64-linux-gnu.tar.gz &>/dev/null
tar -xzf /tmp/dash.tar.gz -C /tmp/ &>/dev/null

cp /tmp/dashcore-0.17.0/bin/* /usr/local/bin/ &>/dev/null
rm -r /tmp/dashcore-0.17.0 &>/dev/null
rm /tmp/dash.tar.gz &>/dev/null

curl -#o /etc/supervisor/conf.d/dash.conf https://raw.githubusercontent.com/lamassu/lamassu-patches/master/wallets/reindex/dash/dash-reindex.conf &>/dev/null

supervisorctl reread &>/dev/null
supervisorctl update dash &>/dev/null

sleep 5s

curl -#o /etc/supervisor/conf.d/dash.conf https://raw.githubusercontent.com/lamassu/lamassu-patches/master/wallets/reindex/dash/dash.conf &>/dev/null

sleep 10s

supervisorctl reread &>/dev/null
supervisorctl update dash &>/dev/null

echo
echo "Done. Your latest wallet balance will be displayed after the blockchain has fully reindexed."
echo
echo "This may take some time. Use the KB article 'Checking wallet synchronization' for current status."
echo
