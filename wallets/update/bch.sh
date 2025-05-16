#!/bin/bash
set -e

export LOG_FILE=/tmp/bch-update.$(date +"%Y%m%d").log

echo
echo "Updating Bitcoin Cash. This may take a minute..."
echo

echo "Downloading Bitcoin Cash Node v28.0.1..."
sourceHash=$'d69ee632147f886ca540cecdff5b1b85512612b4c005e86b09083a63c35b64fa'
curl -#Lo /tmp/bitcoincash.tar.gz https://github.com/bitcoin-cash-node/bitcoin-cash-node/releases/download/v28.0.1/bitcoin-cash-node-28.0.1-x86_64-linux-gnu.tar.gz >> ${LOG_FILE} 2>&1
hash=$(sha256sum /tmp/bitcoincash.tar.gz | awk '{print $1}' | sed 's/ *$//g')

if [ $hash != $sourceHash ] ; then
        echo 'Package signature do not match!'
        exit 1
fi

supervisorctl stop bitcoincash >> ${LOG_FILE} 2>&1
tar -xzf /tmp/bitcoincash.tar.gz -C /tmp/ >> ${LOG_FILE} 2>&1
echo


echo "Updating wallet..."
cp /tmp/bitcoin-cash-node-28.0.1/bin/bitcoind /usr/local/bin/bitcoincashd >> ${LOG_FILE} 2>&1
cp /tmp/bitcoin-cash-node-28.0.1/bin/bitcoin-cli /usr/local/bin/bitcoincash-cli >> ${LOG_FILE} 2>&1
rm -r /tmp/bitcoin-cash-node-28.0.1 >> ${LOG_FILE} 2>&1
rm /tmp/bitcoincash.tar.gz >> ${LOG_FILE} 2>&1
echo

if grep -q "listenonion=" /mnt/blockchains/bitcoincash/bitcoincash.conf
then
    echo "listenonion already defined, skipping..."
else
    echo "Setting 'listenonion=0' in config file..."
    echo -e "\nlistenonion=0" >> /mnt/blockchains/bitcoincash/bitcoincash.conf
fi
echo

if grep -q "bind=0.0.0.0:8335" /mnt/blockchains/bitcoincash/bitcoincash.conf
then
    echo "bind port already updated, skipping..."
else
    echo "Setting 'bind=0.0.0.0:8335' in config file..."
    sed -i 's/bind=0.0.0.0:8334/bind=0.0.0.0:8335/g' /mnt/blockchains/bitcoincash/bitcoincash.conf
fi
echo

if grep -q "rpcport=8336" /mnt/blockchains/bitcoincash/bitcoincash.conf
then
    echo "rpc port already updated, skipping..."
else
    echo "Setting 'rpcport=8336' in config file..."
    sed -i 's/rpcport=8335/rpcport=8336/g' /mnt/blockchains/bitcoincash/bitcoincash.conf
fi
echo

echo "Starting wallet..."
supervisorctl start bitcoincash >> ${LOG_FILE} 2>&1
echo

echo "Bitcoin Cash is updated."
echo
