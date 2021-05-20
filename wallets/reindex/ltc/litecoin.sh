#!/bin/bash
set -e

echo
echo "Updating litecoind and instructing it to reindex the wallet."
echo
echo "This may take a minute..."

supervisorctl stop litecoin &>/dev/null

curl -#o /tmp/litecoin.tar.gz https://download.litecoin.org/litecoin-0.18.1/linux/litecoin-0.18.1-x86_64-linux-gnu.tar.gz &>/dev/null
tar -xzf /tmp/litecoin.tar.gz -C /tmp/ &>/dev/null

cp /tmp/litecoin-0.18.1/bin/* /usr/local/bin/ &>/dev/null
rm -r /tmp/litecoin-0.18.1 &>/dev/null
rm /tmp/litecoin.tar.gz &>/dev/null

curl -#o /etc/supervisor/conf.d/litecoin.conf https://raw.githubusercontent.com/lamassu/lamassu-patches/master/wallets/reindex/ltc/litecoin-reindex.conf &>/dev/null

supervisorctl reread &>/dev/null
supervisorctl update litecoin &>/dev/null

curl -#o /etc/supervisor/conf.d/litecoin.conf https://raw.githubusercontent.com/lamassu/lamassu-patches/master/wallets/reindex/ltc/litecoin.conf &>/dev/null

sleep 10s

supervisorctl reread &>/dev/null
supervisorctl update litecoin &>/dev/null

echo
echo "Done. Your latest wallet balance will be displayed after the blockchain has fully reindexed."
echo
echo "This may take some time. Use the KB article 'Checking wallet synchronization' for current status."
echo
