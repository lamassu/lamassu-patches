#!/bin/bash
set -e

echo
echo "Updating zcashd and instructing it to reindex the wallet."
echo
echo "This may take a minute..."

curl -sS https://raw.githubusercontent.com/lamassu/lamassu-patches/master/wallets/update/zec.sh | bash &>/dev/null

supervisorctl stop zcash &>/dev/null

curl -#o /etc/supervisor/conf.d/zcash.conf https://raw.githubusercontent.com/lamassu/lamassu-patches/master/wallets/reindex/zec/zcash-reindex.conf &>/dev/null

supervisorctl update zcash &>/dev/null

curl -#o /etc/supervisor/conf.d/zcash.conf https://raw.githubusercontent.com/lamassu/lamassu-patches/master/wallets/reindex/zec/zcash.conf &>/dev/null

sleep 10s

supervisorctl update zcash &>/dev/null

echo
echo "Done. Your latest wallet balance will be displayed after the blockchain has fully reindexed."
echo
echo "This may take some time. Use the KB article 'Checking wallet synchronization' for current status."
echo
