#!/bin/bash
set -e

echo
echo "Updating bitcoincashd and instructing it to reindex the wallet."
echo
echo "This may take a minute..."

supervisorctl stop bitcoincash &>/dev/null

curl -sS https://raw.githubusercontent.com/lamassu/lamassu-patches/master/wallets/update/bch.sh | bash &>/dev/null

curl -#o /etc/supervisor/conf.d/bitcoincash.conf https://raw.githubusercontent.com/lamassu/lamassu-patches/master/wallets/reindex/bch/bitcoincash-reindex.conf &>/dev/null

supervisorctl update bitcoincash &>/dev/null

sleep 5s

curl -#o /etc/supervisor/conf.d/bitcoincash.conf https://raw.githubusercontent.com/lamassu/lamassu-patches/master/wallets/reindex/bch/bitcoincash.conf &>/dev/null

sleep 10s

supervisorctl update bitcoincash &>/dev/null

echo
echo "Done. Your latest wallet balance will be displayed after the blockchain has fully reindexed."
echo
echo "This may take some time. Use the KB article 'Checking wallet synchronization' for current status."
echo
