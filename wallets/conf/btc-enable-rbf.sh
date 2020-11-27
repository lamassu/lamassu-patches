#!/bin/bash
set -e

export LOG_FILE=/tmp/btc-rbf-enable.$(date +"%Y%m%d").log

echo
echo "Updating Bitcoin Core to use RBF..."
supervisorctl stop bitcoin >> ${LOG_FILE} 2>&1
echo

if grep -xq "walletrbf=." /mnt/blockchains/bitcoin/bitcoin.conf
then
    echo "RBF setting already defined, skipping..."
else
    echo "Enabling RBF in config file..."
    echo -e "\nwalletrbf=1" >> /mnt/blockchains/bitcoin/bitcoin.conf
fi
echo

echo "Done. Restarting Bitcoin Core..."
supervisorctl start bitcoin >> ${LOG_FILE} 2>&1
echo

echo "Complete. Please refer to our knoweledgebase article on using fee bumping with RBF."
echo