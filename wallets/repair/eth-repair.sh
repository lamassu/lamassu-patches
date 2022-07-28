#!/bin/bash
set -e

d=$(date -u +"%Y-%m-%d_%H-%M-%S")
export LOG_FILE=/tmp/geth-update.$d.log

echo
echo 'Stopping Geth...'
supervisorctl stop ethereum >> ${LOG_FILE} 2>&1

echo
echo 'Moving the blockchain folder to a backup...'
cd /mnt/blockchains/ >> ${LOG_FILE} 2>&1
mv ethereum ethereum-bak-$d >> ${LOG_FILE} 2>&1
mkdir ethereum >> ${LOG_FILE} 2>&1

echo
echo 'Updating Geth...'
curl -#o /tmp/ethereum.tar.gz https://gethstore.blob.core.windows.net/builds/geth-linux-amd64-1.10.21-67109427.tar.gz >> ${LOG_FILE} 2>&1
tar -xzf /tmp/ethereum.tar.gz -C /tmp/ >> ${LOG_FILE} 2>&1
cp /tmp/geth-linux-amd64-1.10.21-67109427/geth /usr/local/bin/geth >> ${LOG_FILE} 2>&1
rm -r /tmp/geth-linux-amd64-1.10.21-67109427/ >> ${LOG_FILE} 2>&1
rm /tmp/ethereum.tar.gz >> ${LOG_FILE} 2>&1

echo
echo 'Clearing Ethereum logs...'
mv /var/log/supervisor/ethereum.err.log /var/log/supervisor/ethereum.err.log-$d >> ${LOG_FILE} 2>&1
mv /var/log/supervisor/ethereum.out.log /var/log/supervisor/ethereum.out.log-$d >> ${LOG_FILE} 2>&1

echo
echo "Updating Ethereum configuration file..."
curl -#o /etc/supervisor/conf.d/ethereum.conf https://raw.githubusercontent.com/lamassu/lamassu-patches/master/wallets/conf/ethereum.conf >> ${LOG_FILE} 2>&1

echo
echo 'Starting Geth...'
supervisorctl reread >> ${LOG_FILE} 2>&1
supervisorctl update ethereum >> ${LOG_FILE} 2>&1
supervisorctl start ethereum >> ${LOG_FILE} 2>&1

echo
echo 'Done!'
echo
