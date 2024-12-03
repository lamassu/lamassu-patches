#!/bin/bash
set -e

export LOG_FILE=/tmp/zec-update.$(date +"%Y%m%d").log

echo
echo "Updating your Zcash wallet. This may take a minute."
echo

echo "Downloading Zcash v6.0.0..."
sourceHash=$'3cb82f490e9c8e88007a0216b5261b33ef0fda962b9258441b2def59cb272a4d'
curl -#Lo /tmp/zcash.tar.gz https://download.z.cash/downloads/zcash-6.0.0-linux64-debian-bullseye.tar.gz >> ${LOG_FILE} 2>&1
hash=$(sha256sum /tmp/zcash.tar.gz | awk '{print $1}' | sed 's/ *$//g')

if [ $hash != $sourceHash ] ; then
        echo 'Package signature do not match!'
        exit 1
fi

supervisorctl stop zcash >> ${LOG_FILE} 2>&1
tar -xzf /tmp/zcash.tar.gz -C /tmp/ >> ${LOG_FILE} 2>&1
echo

echo "Updating wallet..."
cp /tmp/zcash-6.0.0/bin/* /usr/local/bin/ >> ${LOG_FILE} 2>&1
rm -r /tmp/zcash-6.0.0 >> ${LOG_FILE} 2>&1
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

if grep -q "allowdeprecated=getnewaddress" /mnt/blockchains/zcash/zcash.conf
then
    echo "allowdeprecated=getnewaddress already defined, skipping..."
else
    echo "Setting 'allowdeprecated=getnewaddress' in config file..."
    echo -e "\nallowdeprecated=getnewaddress" >> /mnt/blockchains/zcash/zcash.conf
fi
echo

echo "Starting wallet..."
supervisorctl start zcash >> ${LOG_FILE} 2>&1
echo

echo "Zcash is updated."
echo
