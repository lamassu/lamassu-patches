#!/bin/bash
set -e

export LOG_FILE=/tmp/zec-update.$(date +"%Y%m%d").log

echo
echo "Updating your Zcash wallet. This may take a minute."
supervisorctl stop zcash >> ${LOG_FILE} 2>&1
echo

echo "Downloading Zcash v5.1.0..."
curl -#Lo /tmp/zcash.tar.gz https://z.cash/downloads/zcash-5.1.0-linux64-debian-bullseye.tar.gz >> ${LOG_FILE} 2>&1
tar -xzf /tmp/zcash.tar.gz -C /tmp/ >> ${LOG_FILE} 2>&1
echo

echo "Updating wallet..."
cp /tmp/zcash-5.1.0/bin/* /usr/local/bin/ >> ${LOG_FILE} 2>&1
rm -r /tmp/zcash-5.1.0 >> ${LOG_FILE} 2>&1
rm /tmp/zcash.tar.gz >> ${LOG_FILE} 2>&1
echo

if grep -q "walletrequirebackup=" /mnt/blockchains/zcash/zcash.conf
then
    echo "walletrequirebackup already defined, skipping..."
else
    echo "Setting 'walletrequirebackup=false' in config file..."
    echo -e "\nwalletrequirebackup=false" >> /mnt/blockchains/zcash/zcash.conf
fi
echo

echo "Starting wallet..."
supervisorctl start zcash >> ${LOG_FILE} 2>&1
echo

echo "Zcash is updated."
echo
