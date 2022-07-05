#!/bin/bash
set -e

d=$(date -u "+%Y%m%d")

echo
echo 'Stopping Bitcoin Cash...'
supervisorctl stop bitcoincash &>/dev/null

echo 'Clearing the database, chainstate, and blocks...'
cd /mnt/blockchains/bitcoincash
mkdir empty-$d
rsync -a --delete empty-$d/ database/
rsync -a --delete empty-$d/ chainstate/
rsync -a --delete empty-$d/ blocks/

echo 'Updating Bitcoin Cash...'
curl -#Lo /tmp/bitcoincash.tar.gz https://github.com/bitcoin-cash-node/bitcoin-cash-node/releases/download/v24.1.0/bitcoin-cash-node-24.1.0-x86_64-linux-gnu.tar.gz &>/dev/null
tar -xzf /tmp/bitcoincash.tar.gz -C /tmp/ &>/dev/null
cp /tmp/bitcoin-cash-node-24.1.0/bin/bitcoind /usr/local/bin/bitcoincashd &>/dev/null
cp /tmp/bitcoin-cash-node-24.1.0/bin/bitcoin-cli /usr/local/bin/bitcoincash-cli &>/dev/null
rm -r /tmp/bitcoin-cash-node-24.1.0 &>/dev/null
rm /tmp/bitcoincash.tar.gz &>/dev/null

echo 'Clearing Bitcoin Cash logs...'
set +e
mv /var/log/supervisor/bitcoincash.err.log /var/log/supervisor/bitcoincash-old.err.log
mv /var/log/supervisor/bitcoincash.out.log /var/log/supervisor/bitcoincash-old.out.log
set -e

echo "Resetting Bitcoin Cash configurations..."
sed -i 's/\<connections\>/maxconnections/g' /mnt/blockchains/bitcoincash/bitcoincash.conf &>/dev/null
curl -#o /etc/supervisor/conf.d/bitcoin.conf https://raw.githubusercontent.com/lamassu/lamassu-patches/master/wallets/repair/bitcoincash.conf &>/dev/null
supervisorctl reread &>/dev/null
supervisorctl update bitcoincash &>/dev/null

echo 'Starting Bitcoin Cash...'
supervisorctl start bitcoincash &>/dev/null
supervisorctl restart lamassu-server lamassu-admin-server &>/dev/null

echo 'Done!'
echo
