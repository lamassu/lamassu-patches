#!/bin/bash
set -e

echo
echo "Updating litecoind and instructing it to reindex the wallet."
echo
echo "This may take a minute..."

curl -sS https://raw.githubusercontent.com/lamassu/lamassu-patches/master/wallets/update/ltc.sh | bash &>/dev/null

supervisorctl stop litecoin &>/dev/null

curl -#o /etc/supervisor/conf.d/litecoin.conf https://raw.githubusercontent.com/lamassu/lamassu-patches/master/wallets/reindex/ltc/litecoin-reindex.conf &>/dev/null

supervisorctl update litecoin &>/dev/null

sleep 5s

curl -#o /etc/supervisor/conf.d/litecoin.conf https://raw.githubusercontent.com/lamassu/lamassu-patches/master/wallets/reindex/ltc/litecoin.conf &>/dev/null

sleep 10s

supervisorctl update litecoin &>/dev/null

echo
echo "Done. Your latest wallet balance will be displayed after the blockchain has fully reindexed."
echo
echo "This may take some time. Use the KB article 'Checking wallet synchronization' for current status."
echo
