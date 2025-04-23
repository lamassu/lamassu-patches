#!/bin/bash
set -e

export LOG_FILE=/tmp/zec-update.$(date +"%Y%m%d").log

echo
echo "Updating your Zcash wallet. This may take a minute."
echo

echo "Downloading Zcash v6.2.0..."
sourceHash=$'71cf378c27582a4b9f9d57cafc2b5a57a46e9e52a5eda33be112dc9790c64c6f'
curl -#Lo /tmp/zcash.tar.gz https://download.z.cash/downloads/zcash-6.2.0-linux64-debian-bullseye.tar.gz >> ${LOG_FILE} 2>&1
hash=$(sha256sum /tmp/zcash.tar.gz | awk '{print $1}' | sed 's/ *$//g')

if [ $hash != $sourceHash ] ; then
        echo 'Package signature do not match!'
        exit 1
fi

supervisorctl stop zcash >> ${LOG_FILE} 2>&1
tar -xzf /tmp/zcash.tar.gz -C /tmp/ >> ${LOG_FILE} 2>&1
echo

echo "Updating wallet..."
cp /tmp/zcash-6.2.0/bin/* /usr/local/bin/ >> ${LOG_FILE} 2>&1
rm -r /tmp/zcash-6.2.0 >> ${LOG_FILE} 2>&1
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

if grep -q "i-am-aware-zcashd-will-be-replaced-by-zebrad-and-zallet-in-2025=1" /mnt/blockchains/zcash/zcash.conf
then
    echo "i-am-aware already defined, skipping..."
else
    echo "Setting 'i-am-aware' in config file..."
    echo -e "\ni-am-aware-zcashd-will-be-replaced-by-zebrad-and-zallet-in-2025=1" >> /mnt/blockchains/zcash/zcash.conf
fi
echo

echo "Starting wallet..."
supervisorctl start zcash >> ${LOG_FILE} 2>&1
echo

echo "Zcash is updated."
echo
