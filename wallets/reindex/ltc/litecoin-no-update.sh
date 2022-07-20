#!/bin/bash
set -e

echo
echo "Instructing litecoind to reindex."
echo
echo "This will take a moment..."

supervisorctl stop litecoin &>/dev/null

curl -#o /etc/supervisor/conf.d/litecoin.conf https://raw.githubusercontent.com/lamassu/lamassu-patches/master/wallets/reindex/ltc/litecoin-reindex.conf &>/dev/null

supervisorctl update litecoin &>/dev/null

sleep 5s

curl -#o /etc/supervisor/conf.d/litecoin.conf https://raw.githubusercontent.com/lamassu/lamassu-patches/master/wallets/reindex/ltc/litecoin.conf &>/dev/null

sleep 10s

supervisorctl update litecoin &>/dev/null

echo
echo "Done. Reindexing may take some time. Use the KB article 'Checking wallet synchronisation' for current status."
echo
