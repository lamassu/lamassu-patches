#!/bin/bash
set -e

export LOG_FILE=/tmp/bch-update.$(date +"%Y%m%d").log

echo
echo "Updating Bitcoin Cash. This may take a minute..."
echo

echo "Downloading Bitcoin Cash Node v24.1.0..."
sourceHash=$'857b6b95c54d84756fdd86893cd238a9b100c471a0b235aca4246cca74112ca9'
curl -#Lo /tmp/bitcoincash.tar.gz https://github.com/bitcoin-cash-node/bitcoin-cash-node/releases/download/v24.1.0/bitcoin-cash-node-24.1.0-x86_64-linux-gnu.tar.gz >> ${LOG_FILE} 2>&1
hash=$(sha256sum /tmp/bitcoincash.tar.gz | awk '{print $1}' | sed 's/ *$//g')

if [ $hash != $sourceHash ] ; then
        echo 'Package signature do not match!'
        exit 1
fi

supervisorctl stop bitcoincash >> ${LOG_FILE} 2>&1
tar -xzf /tmp/bitcoincash.tar.gz -C /tmp/ >> ${LOG_FILE} 2>&1
echo


echo "Updating wallet..."
cp /tmp/bitcoin-cash-node-24.1.0/bin/bitcoind /usr/local/bin/bitcoincashd >> ${LOG_FILE} 2>&1
cp /tmp/bitcoin-cash-node-24.1.0/bin/bitcoin-cli /usr/local/bin/bitcoincash-cli >> ${LOG_FILE} 2>&1
rm -r /tmp/bitcoin-cash-node-24.1.0 >> ${LOG_FILE} 2>&1
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
