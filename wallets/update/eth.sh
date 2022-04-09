#!/bin/bash
set -e

export LOG_FILE=/tmp/eth-update.$(date +"%Y%m%d").log

echo
echo "Updating the Geth Ethereum wallet. This may take a minute."
supervisorctl stop ethereum >> ${LOG_FILE} 2>&1
echo

echo "Updating Ethereum configuration file..."
curl -#o /etc/supervisor/conf.d/ethereum.conf https://raw.githubusercontent.com/lamassu/lamassu-patches/master/wallets/conf/ethereum.conf >> ${LOG_FILE} 2>&1
echo

echo "Downloading Geth v1.10.17..."
curl -#o /tmp/ethereum.tar.gz https://gethstore.blob.core.windows.net/builds/geth-linux-amd64-1.10.17-25c9b49f.tar.gz >> ${LOG_FILE} 2>&1
tar -xzf /tmp/ethereum.tar.gz -C /tmp/ >> ${LOG_FILE} 2>&1
echo

echo "Updating..."
cp /tmp/geth-linux-amd64-1.10.17-25c9b49f/geth /usr/local/bin/geth >> ${LOG_FILE} 2>&1
rm -r /tmp/geth-linux-amd64-1.10.17-25c9b49f/ >> ${LOG_FILE} 2>&1
rm /tmp/ethereum.tar.gz >> ${LOG_FILE} 2>&1
echo

echo "Starting wallet..."
supervisorctl reread >> ${LOG_FILE} 2>&1
supervisorctl update ethereum >> ${LOG_FILE} 2>&1
supervisorctl start ethereum >> ${LOG_FILE} 2>&1
echo

echo "Geth is updated."
echo
