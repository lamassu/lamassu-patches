#!/bin/bash
set -e

export LOG_FILE=/tmp/btc-update.$(date +"%Y%m%d").log

echo
echo "Updating Bitcoin Core. This may take a minute."
echo

echo "Downloading v25.0..."
sourceHash=$'33930d432593e49d58a9bff4c30078823e9af5d98594d2935862788ce8a20aec'
curl -#o /tmp/bitcoin.tar.gz https://bitcoincore.org/bin/bitcoin-core-25.0/bitcoin-25.0-x86_64-linux-gnu.tar.gz >> ${LOG_FILE} 2>&1
hash=$(sha256sum /tmp/bitcoin.tar.gz | awk '{print $1}' | sed 's/ *$//g')

if [ $hash != $sourceHash ] ; then
        echo 'Package signature do not match!'
        exit 1
fi

supervisorctl stop bitcoin >> ${LOG_FILE} 2>&1
tar -xzf /tmp/bitcoin.tar.gz -C /tmp/ >> ${LOG_FILE} 2>&1
echo

echo "Updating wallet..."
cp /tmp/bitcoin-25.0/bin/* /usr/local/bin/ >> ${LOG_FILE} 2>&1
rm -r /tmp/bitcoin-25.0 >> ${LOG_FILE} 2>&1
rm /tmp/bitcoin.tar.gz >> ${LOG_FILE} 2>&1
echo

if grep -q "addresstype=p2sh-segwit" /mnt/blockchains/bitcoin/bitcoin.conf
then
    sed -i 's/addresstype=p2sh-segwit/addresstype=bech32/g' /mnt/blockchains/bitcoin/bitcoin.conf
else
    echo "bech32 receiving addresses already defined, skipping..."
fi
echo

if grep -q "changetype=" /mnt/blockchains/bitcoin/bitcoin.conf
then
    echo "changetype already defined, skipping..."
else
    echo "Enabling bech32 change addresses in config file..."
    echo -e "\nchangetype=bech32" >> /mnt/blockchains/bitcoin/bitcoin.conf
fi
echo

if grep -q "listenonion=" /mnt/blockchains/bitcoin/bitcoin.conf
then
    echo "listenonion already defined, skipping..."
else
    echo "Setting 'listenonion=0' in config file..."
    echo -e "\nlistenonion=0" >> /mnt/blockchains/bitcoin/bitcoin.conf
fi
echo

if grep -q "walletrbf=" /mnt/blockchains/bitcoin/bitcoin.conf
then
    echo "RBF setting already defined, skipping..."
else
    echo "Enabling RBF in config file..."
    echo -e "\nwalletrbf=1" >> /mnt/blockchains/bitcoin/bitcoin.conf
fi
echo

echo "Starting wallet..."
supervisorctl start bitcoin >> ${LOG_FILE} 2>&1
echo

echo "Bitcoin Core is updated."
echo
