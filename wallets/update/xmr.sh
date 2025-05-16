#!/bin/bash
set -e

export LOG_FILE=/tmp/monero-update.$(date +"%Y%m%d").log

echo
echo "Updating your Monero wallet. This may take a minute."
echo

echo "Downloading Monero v0.18.4.0..."
sourceHash=$'16cb74c899922887827845a41d37c7f3121462792a540843f2fcabcc1603993f'
curl -#Lo /tmp/monero.tar.bz2 https://downloads.getmonero.org/cli/monero-linux-x64-v0.18.4.0.tar.bz2 >> ${LOG_FILE} 2>&1
hash=$(sha256sum /tmp/monero.tar.bz2 | awk '{print $1}' | sed 's/ *$//g')

if [ $hash != $sourceHash ] ; then
        echo 'Package signature do not match!'
        exit 1
fi

supervisorctl stop monero monero-wallet >> ${LOG_FILE} 2>&1
tar -xf /tmp/monero.tar.bz2 -C /tmp/ >> ${LOG_FILE} 2>&1
echo

echo "Updating wallet..."
cp /tmp/monero-x86_64-linux-gnu-v0.18.4.0/monerod /usr/local/bin/ >> ${LOG_FILE} 2>&1
cp /tmp/monero-x86_64-linux-gnu-v0.18.4.0/monero-wallet-rpc /usr/local/bin/ >> ${LOG_FILE} 2>&1
rm -r /tmp/monero-x86_64-linux-gnu-v0.18.4.0 >> ${LOG_FILE} 2>&1
rm /tmp/monero.tar.bz2 >> ${LOG_FILE} 2>&1
echo

echo "Starting wallet..."
supervisorctl start monero monero-wallet >> ${LOG_FILE} 2>&1
echo

echo "Monero is updated."
echo
