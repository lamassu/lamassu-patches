#!/bin/bash
set -e

export LOG_FILE=/tmp/bch-update.$(date +"%Y%m%d").log

echo
echo "Updating Bitcoin Cash. This may take a minute..."
supervisorctl stop bitcoincash >> ${LOG_FILE} 2>&1
echo

echo "Downloading Bitcoin Cash Node v22.1.0..."
curl -#Lo /tmp/bitcoincash.tar.gz https://github.com/bitcoin-cash-node/bitcoin-cash-node/releases/download/v22.1.0/bitcoin-cash-node-22.1.0-x86_64-linux-gnu.tar.gz >> ${LOG_FILE} 2>&1
tar -xzf /tmp/bitcoincash.tar.gz -C /tmp/ >> ${LOG_FILE} 2>&1
echo

echo "Updating wallet..."
mv /usr/local/bin/bitcoincashd /usr/local/bin/bitcoincashd-old >> ${LOG_FILE} 2>&1
mv /usr/local/bin/bitcoincash-cli /usr/local/bin/bitcoin-cli-old >> ${LOG_FILE} 2>&1
cp /tmp/bitcoin-cash-node-22.1.0/bin/bitcoind /usr/local/bin/bitcoincashd >> ${LOG_FILE} 2>&1
cp /tmp/bitcoin-cash-node-22.1.0/bin/bitcoin-cli /usr/local/bin/bitcoincash-cli >> ${LOG_FILE} 2>&1
rm -r /tmp/bitcoin-cash-node-22.1.0 >> ${LOG_FILE} 2>&1
rm /tmp/bitcoincash.tar.gz >> ${LOG_FILE} 2>&1
echo

echo "Starting wallet..."
supervisorctl start bitcoincash >> ${LOG_FILE} 2>&1
echo

echo "Bitcoin Cash is updated."
echo
