#!/bin/bash
set -e

export LOG_FILE=/tmp/ltc-update.$(date +"%Y%m%d").log

echo
echo "Updating Litecoin Core. This may take a minute."
echo

echo "Downloading v0.21.3..."
sourceHash=$'ea231c630e2a243cb01affd4c2b95a2be71560f80b64b9f4bceaa13d736aa7cb'
curl -#o /tmp/litecoin.tar.gz https://download.litecoin.org/litecoin-0.21.3/linux/litecoin-0.21.3-x86_64-linux-gnu.tar.gz >> ${LOG_FILE} 2>&1
hash=$(sha256sum /tmp/litecoin.tar.gz | awk '{print $1}' | sed 's/ *$//g')

if [ $hash != $sourceHash ] ; then
        echo 'Package signature do not match!'
        exit 1
fi

supervisorctl stop litecoin >> ${LOG_FILE} 2>&1
tar -xzf /tmp/litecoin.tar.gz -C /tmp/ >> ${LOG_FILE} 2>&1
echo

echo "Updating wallet..."
cp /tmp/litecoin-0.21.3/bin/* /usr/local/bin/ >> ${LOG_FILE} 2>&1
rm -r /tmp/litecoin-0.21.3 >> ${LOG_FILE} 2>&1
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

if grep -q "blockfilterindex=" /mnt/blockchains/litecoin/litecoin.conf
then
    echo "blockfilterindex already defined, skipping..."
else
    echo "Disabling blockfilterindex in config file..."
    echo -e "\nblockfilterindex=0" >> /mnt/blockchains/litecoin/litecoin.conf
fi
echo

if grep -q "peerblockfilters=" /mnt/blockchains/litecoin/litecoin.conf
then
    echo "peerblockfilters already defined, skipping..."
else
    echo "Disabling peerblockfilters in config file..."
    echo -e "\npeerblockfilters=0" >> /mnt/blockchains/litecoin/litecoin.conf
fi
echo

echo "Starting wallet..."
supervisorctl start litecoin >> ${LOG_FILE} 2>&1
echo

echo "Litecoin Core is updated."
echo
