#!/bin/bash
set -e

export LOG_FILE=/tmp/btc-update.$(date +"%Y%m%d").log

echo
echo "Updating Bitcoin Core. This may take a minute."
supervisorctl stop bitcoin >> ${LOG_FILE} 2>&1
echo

echo "Downloading v22.0..."
curl -#o /tmp/bitcoin.tar.gz https://bitcoincore.org/bin/bitcoin-core-22.0/bitcoin-22.0-x86_64-linux-gnu.tar.gz >> ${LOG_FILE} 2>&1
tar -xzf /tmp/bitcoin.tar.gz -C /tmp/ >> ${LOG_FILE} 2>&1
echo

echo "Updating wallet..."
cp /tmp/bitcoin-22.0/bin/* /usr/local/bin/ >> ${LOG_FILE} 2>&1
rm -r /tmp/bitcoin-22.0 >> ${LOG_FILE} 2>&1
rm /tmp/bitcoin.tar.gz >> ${LOG_FILE} 2>&1
echo

if grep -q "changetype=" /mnt/blockchains/bitcoin/bitcoin.conf
then
    echo "changetype already defined, skipping..."
else
    echo "Enabling bech32 change addresses in config file..."
    echo -e "changetype=bech32" >> /mnt/blockchains/bitcoin/bitcoin.conf
fi
echo

echo "Starting wallet..."
supervisorctl start bitcoin >> ${LOG_FILE} 2>&1
echo

echo "Bitcoin Core is updated."
echo
