#!/bin/bash
set -e

echo
echo "Updating bitcoind and instructing it to reindex the wallet."
echo
echo "This may take a minute..."

supervisorctl stop bitcoin &>/dev/null

curl -#o /tmp/bitcoin.tar.gz https://bitcoincore.org/bin/bitcoin-core-0.20.1/bitcoin-0.20.1-x86_64-linux-gnu.tar.gz &>/dev/null
tar -xzf /tmp/bitcoin.tar.gz -C /tmp/ &>/dev/null

cp /tmp/bitcoin-0.20.1/bin/* /usr/local/bin/ &>/dev/null
rm -r /tmp/bitcoin-0.20.1 &>/dev/null
rm /tmp/bitcoin.tar.gz &>/dev/null

curl -#o /etc/supervisor/conf.d/bitcoin.conf https://raw.githubusercontent.com/lamassu/lamassu-patches/master/wallets/reindex/btc/bitcoin-reindex.conf &>/dev/null

supervisorctl reread &>/dev/null
supervisorctl update bitcoin &>/dev/null

curl -#o /etc/supervisor/conf.d/bitcoin.conf https://raw.githubusercontent.com/lamassu/lamassu-patches/master/wallets/reindex/btc/bitcoin.conf &>/dev/null

sleep 10s

supervisorctl reread &>/dev/null
supervisorctl update bitcoin &>/dev/null

echo
echo "Done. Your latest wallet balance will be displayed after the blockchain has fully reindexed."
echo
echo "This may take some time. Use the KB article 'Checking wallet synchronization' for current status."
echo
