#!/bin/bash
set -e

echo "Telling bitcoincashd to reindex the wallet..."
echo

curl -#o /etc/supervisor/conf.d/bitcoincash.conf https://raw.githubusercontent.com/lamassu/lamassu-patches/master/wallets/reindex/bch/bitcoincash-reindex.conf &>/dev/null

supervisorctl reread bitcoincash &>/dev/null
supervisorctl update bitcoincash &>/dev/null

curl -#o /etc/supervisor/conf.d/bitcoincash.conf https://raw.githubusercontent.com/lamassu/lamassu-patches/master/wallets/reindex/bch/bitcoincash.conf &>/dev/null

echo "Done. Your latest wallet balance will be displayed after the Bitcoin Cash wallet has fully reindexed."
echo
echo "This may take some time. Use the KB article 'Checking wallet synchronization' for current status."
echo
