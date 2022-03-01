#!/bin/bash
set -e

export LOG_FILE=/tmp/ltc-update.$(date +"%Y%m%d").log

echo
echo "Updating Litecoin Core. This may take a minute."
supervisorctl stop litecoin >> ${LOG_FILE} 2>&1
echo

echo "Downloading v0.18.1..."
curl -#o /tmp/litecoin.tar.gz https://download.litecoin.org/litecoin-0.18.1/linux/litecoin-0.18.1-x86_64-linux-gnu.tar.gz >> ${LOG_FILE} 2>&1
tar -xzf /tmp/litecoin.tar.gz -C /tmp/ >> ${LOG_FILE} 2>&1
echo

echo "Updating wallet..."
cp /tmp/litecoin-0.18.1/bin/* /usr/local/bin/ >> ${LOG_FILE} 2>&1
rm -r /tmp/litecoin-0.18.1 >> ${LOG_FILE} 2>&1
rm /tmp/litecoin.tar.gz >> ${LOG_FILE} 2>&1
echo

if grep -q "changetype=" /mnt/blockchains/litecoin/litecoin.conf
then
    echo "changetype already defined, skipping..."
else
    echo "Enabling bech32 change addresses in config file..."
    echo -e "\nchangetype=bech32" >> /mnt/blockchains/litecoin/litecoin.conf
fi
echo

echo "Starting wallet..."
supervisorctl start litecoin >> ${LOG_FILE} 2>&1
echo

echo "Litecoin Core is updated."
echo
