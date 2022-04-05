#!/bin/bash
set -e

echo
echo "Updating bitcoind and instructing it to reindex the wallet."
echo
echo "This may take a minute..."

curl -sS https://raw.githubusercontent.com/lamassu/lamassu-patches/master/wallets/update/btc.sh | bash &>/dev/null

supervisorctl stop bitcoin &>/dev/null

curl -#o /etc/supervisor/conf.d/bitcoin.conf https://raw.githubusercontent.com/lamassu/lamassu-patches/master/wallets/reindex/btc/bitcoin-reindex.conf &>/dev/null

sleep 5s

supervisorctl update bitcoin &>/dev/null

curl -#o /etc/supervisor/conf.d/bitcoin.conf https://raw.githubusercontent.com/lamassu/lamassu-patches/master/wallets/reindex/btc/bitcoin.conf &>/dev/null

sleep 10s

supervisorctl update bitcoin &>/dev/null

echo
echo "Done. Your latest wallet balance will be displayed after the blockchain has fully reindexed."
echo
echo "This may take some time. Use the KB article 'Checking wallet synchronization' for current status."
echo
