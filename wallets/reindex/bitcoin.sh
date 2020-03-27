#!/bin/bash
set -e

echo "Telling bitcoind to reindex the wallet..."
echo
curl -#o /etc/supervisor/conf.d/bitcoin.conf https://raw.githubusercontent.com/lamassu/lamassu-patches/master/wallets/reindex/bitcoin-reindex.conf &>/dev/null
supervisorctl update bitcoin &>/dev/null
curl -#o /etc/supervisor/conf.d/bitcoin.conf https://raw.githubusercontent.com/lamassu/lamassu-patches/master/wallets/reindex/bitcoin.conf &>/dev/null
echo "Done. Your latest wallet balance will be displayed after the Bitcoin wallet has fully reindexed."
echo
echo "This may take some time. Use the KB article 'Checking wallet synchronization' for current status."
echo
