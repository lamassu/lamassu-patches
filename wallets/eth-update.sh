#!/bin/bash
set -e

export LOG_FILE=/tmp/eth-update.$(date +"%Y%m%d").log

echo
echo "Updating the Geth Ethereum wallet. This may take a minute."
supervisorctl stop ethereum >> ${LOG_FILE} 2>&1
echo

echo "Downloading Geth v1.10.7..."
curl -#o /tmp/ethereum.tar.gz https://gethstore.blob.core.windows.net/builds/geth-linux-amd64-1.10.7-12f0ff40.tar.gz >> ${LOG_FILE} 2>&1
tar -xzf /tmp/ethereum.tar.gz -C /tmp/ >> ${LOG_FILE} 2>&1
echo

echo "Updating..."
cp /tmp/geth-linux-amd64-1.10.7-12f0ff40/geth /usr/local/bin/geth >> ${LOG_FILE} 2>&1
rm -r /tmp/geth-linux-amd64-1.10.7-12f0ff40/ >> ${LOG_FILE} 2>&1
rm /tmp/ethereum.tar.gz >> ${LOG_FILE} 2>&1
echo

echo "Starting wallet..."
supervisorctl start ethereum >> ${LOG_FILE} 2>&1
echo

echo "Geth is updated."
echo
