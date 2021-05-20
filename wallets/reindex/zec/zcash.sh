#!/bin/bash
set -e

echo
echo "Updating zcashd and instructing it to reindex the wallet."
echo
echo "This may take a minute..."

supervisorctl stop zcash &>/dev/null

curl -#Lo /tmp/zcash.tar.gz https://z.cash/downloads/zcash-4.4.0-linux64-debian-stretch.tar.gz &>/dev/null
tar -xzf /tmp/zcash.tar.gz -C /tmp/ &>/dev/null

cp /tmp/zcash-4.4.0/bin/* /usr/local/bin/ &>/dev/null
rm -r /tmp/zcash-4.4.0 &>/dev/null
rm /tmp/zcash.tar.gz &>/dev/null

curl -#o /etc/supervisor/conf.d/zcash.conf https://raw.githubusercontent.com/lamassu/lamassu-patches/master/wallets/reindex/zec/zcash-reindex.conf &>/dev/null

supervisorctl reread &>/dev/null
supervisorctl update zcash &>/dev/null

curl -#o /etc/supervisor/conf.d/zcash.conf https://raw.githubusercontent.com/lamassu/lamassu-patches/master/wallets/reindex/zec/zcash.conf &>/dev/null

sleep 10s

supervisorctl reread &>/dev/null
supervisorctl update zcash &>/dev/null

echo
echo "Done. Your latest wallet balance will be displayed after the blockchain has fully reindexed."
echo
echo "This may take some time. Use the KB article 'Checking wallet synchronization' for current status."
echo
