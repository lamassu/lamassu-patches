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
curl -#o /tmp/bitcoincash.tar.gz https://github.com/bitcoin-cash-node/bitcoin-cash-node/releases/download/v24.1.0/bitcoin-cash-node-24.1.0-x86_64-linux-gnu.tar.gz >> ${LOG_FILE} 2>&1
tar -xzf /tmp/bitcoincash.tar.gz -C /tmp/ >> ${LOG_FILE} 2>&1
cp /tmp/bitcoin-cash-node-24.1.0/bin/bitcoind /usr/local/bin/bitcoincashd >> ${LOG_FILE} 2>&1
cp /tmp/bitcoin-cash-node-24.1.0/bin/bitcoin-cli /usr/local/bin/bitcoincash-cli >> ${LOG_FILE} 2>&1
rm -r /tmp/bitcoin-cash-node-24.1.0 >> ${LOG_FILE} 2>&1
rm /tmp/bitcoincash.tar.gz >> ${LOG_FILE} 2>&1

echo 'Clearing Bitcoin Cash logs...'
rm /var/log/supervisor/bitcoincash.err.log
rm /var/log/supervisor/bitcoincash.out.log

echo "Resetting Bitcoin Cash configurations..."
sed -i 's/\<connections\>/maxconnections/g' /mnt/blockchains/bitcoincash/bitcoincash.conf >> ${LOG_FILE} 2>&1
curl -#o /etc/supervisor/conf.d/bitcoin.conf https://raw.githubusercontent.com/lamassu/lamassu-patches/master/wallets/repair/bitcoincash.conf >> ${LOG_FILE} 2>&1
supervisorctl reread bitcoincash >> ${LOG_FILE} 2>&1
supervisorctl update bitcoincash >> ${LOG_FILE} 2>&1

echo 'Starting Bitcoin Cash...'
supervisorctl start bitcoincash >> ${LOG_FILE} 2>&1
supervisorctl restart lamassu-server lamassu-admin-server >> ${LOG_FILE} 2>&1

echo 'Done!'
echo
