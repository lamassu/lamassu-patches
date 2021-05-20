#!/bin/bash
set -e

echo "Updating bitcoincashd and instructing it to reindex the wallet."
echo
echo "This may take a minute..."

supervisorctl stop bitcoincash &>/dev/null

curl -#Lo /tmp/bitcoincash.tar.gz https://github.com/bitcoin-cash-node/bitcoin-cash-node/releases/download/v23.0.0/bitcoin-cash-node-23.0.0-x86_64-linux-gnu.tar.gz &>/dev/null
tar -xzf /tmp/bitcoincash.tar.gz -C /tmp/ &>/dev/null

cp /tmp/bitcoin-cash-node-23.0.0/bin/* /usr/local/bin/ &>/dev/null
rm -r /tmp/bitcoin-cash-node-23.0.0 &>/dev/null
rm /tmp/bitcoincash.tar.gz &>/dev/null

curl -#o /etc/supervisor/conf.d/bitcoincash.conf https://raw.githubusercontent.com/lamassu/lamassu-patches/master/wallets/reindex/bch/bitcoincash-reindex.conf &>/dev/null

supervisorctl reread &>/dev/null
supervisorctl update bitcoincash &>/dev/null

curl -#o /etc/supervisor/conf.d/bitcoincash.conf https://raw.githubusercontent.com/lamassu/lamassu-patches/master/wallets/reindex/bch/bitcoincash.conf &>/dev/null

sleep 10s

supervisorctl reread &>/dev/null
supervisorctl update bitcoincash &>/dev/null

echo
echo "Done. Your latest wallet balance will be displayed after the blockchain has fully reindexed."
echo
echo "This may take some time. Use the KB article 'Checking wallet synchronization' for current status."
echo
