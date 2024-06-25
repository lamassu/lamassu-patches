#!/bin/bash
set -e

echo
echo "Updating monerod and instructing it to reindex the wallet."
echo
echo "This may take a minute..."

curl -sS https://raw.githubusercontent.com/lamassu/lamassu-patches/master/wallets/update/xmr.sh | bash &>/dev/null

supervisorctl stop monero monero-wallet &>/dev/null

curl -#o /etc/supervisor/conf.d/monero.conf https://raw.githubusercontent.com/lamassu/lamassu-patches/master/wallets/reindex/xmr/monero-reindex.conf &>/dev/null

supervisorctl update monero &>/dev/null
supervisorctl start monero-wallet &>/dev/null

sleep 10s

curl -#o /etc/supervisor/conf.d/monero.conf https://raw.githubusercontent.com/lamassu/lamassu-patches/master/wallets/reindex/xmr/monero.conf &>/dev/null

supervisorctl update monero &>/dev/null

echo
echo "Done. Your latest wallet balance will be displayed after the blockchain has fully reindexed."
echo
echo "This may take some time. Use the KB article 'Checking wallet synchronization' for current status."
echo
