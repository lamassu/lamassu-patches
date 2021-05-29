#!/bin/bash
set -e

export LOG_FILE=/tmp/btc-update.$(date +"%Y%m%d").log

echo
echo "Updating Bitcoin Core. This may take a minute."
supervisorctl stop bitcoin >> ${LOG_FILE} 2>&1
echo

echo "Downloading v0.19.1..."
curl -#o /tmp/bitcoin.tar.gz https://bitcoincore.org/bin/bitcoin-core-0.19.1/bitcoin-0.19.1-x86_64-linux-gnu.tar.gz >> ${LOG_FILE} 2>&1
tar -xzf /tmp/bitcoin.tar.gz -C /tmp/ >> ${LOG_FILE} 2>&1
echo

echo "Updating wallet..."
cp /tmp/bitcoin-0.19.1/bin/* /usr/local/bin/ >> ${LOG_FILE} 2>&1
rm -r /tmp/bitcoin-0.19.1 >> ${LOG_FILE} 2>&1
rm /tmp/bitcoin.tar.gz >> ${LOG_FILE} 2>&1
echo

echo "Starting wallet..."
supervisorctl start bitcoin >> ${LOG_FILE} 2>&1
echo

echo "Bitcoin Core is updated."
echo
