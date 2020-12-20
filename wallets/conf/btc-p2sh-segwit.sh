#!/bin/bash
set -e

export LOG_FILE=/tmp/btc-p2sh-segwit.$(date +"%Y%m%d").log

echo
echo "Updating Bitcoin Core to use P2SH SegWit addresses..."
supervisorctl stop bitcoin >> ${LOG_FILE} 2>&1
echo

if grep -xq "addresstype=." /mnt/blockchains/bitcoin/bitcoin.conf
then
    echo "Address type setting already defined, skipping..."
else
    echo "Setting default address type in config file..."
    echo -e "\addresstype=p2sh-segwit" >> /mnt/blockchains/bitcoin/bitcoin.conf
fi
echo

echo "Done. Restarting Bitcoin Core..."
supervisorctl start bitcoin >> ${LOG_FILE} 2>&1
echo

echo "Complete. Deposit addresses will now begin with '3' instead of 'bc1'."
echo
