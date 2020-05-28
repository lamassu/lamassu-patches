#!/bin/bash
set -e

export LOG_FILE=/tmp/eth-update.$(date +"%Y%m%d").log

echo
echo "Updating Ethereum. This may take a minute."
supervisorctl stop ethereum >> ${LOG_FILE} 2>&1

echo
echo "Downloading..."
curl -#o /tmp/ethereum.tar.gz https://gethstore.blob.core.windows.net/builds/geth-linux-amd64-1.9.14-6d74d1e5.tar.gz >> ${LOG_FILE} 2>&1
tar -xzf /tmp/ethereum.tar.gz -C /tmp/ >> ${LOG_FILE} 2>&1

echo
echo "Updating..."
mv /usr/local/bin/geth /usr/local/bin/geth-old >> ${LOG_FILE} 2>&1
cp /tmp/geth-linux-amd64-1.9.14-6d74d1e5/geth /usr/local/bin/geth >> ${LOG_FILE} 2>&1
rm -r /tmp/geth-linux-amd64-1.9.14-6d74d1e5/ >> ${LOG_FILE} 2>&1
rm /tmp/ethereum.tar.gz >> ${LOG_FILE} 2>&1
supervisorctl start ethereum >> ${LOG_FILE} 2>&1

echo
echo "Ethereum is updated."
