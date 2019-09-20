#!/bin/bash
set -e

export LOG_FILE=/tmp/bch-update.$(date +"%Y%m%d").log

echo
echo "Updating Bitcoin Cash. This may take a minute..."
supervisorctl stop bitcoincash >> ${LOG_FILE} 2>&1

echo "Downloading..."
curl -#o /tmp/bitcoincash.tar.gz https://download.bitcoinabc.org/0.20.2/linux/bitcoin-abc-0.20.2-x86_64-linux-gnu.tar.gz >> ${LOG_FILE} 2>&1
tar -xzf /tmp/bitcoincash.tar.gz -C /tmp/ >> ${LOG_FILE} 2>&1

echo "Updating..."
mv /usr/local/bin/bitcoincashd /usr/local/bin/bitcoincashd-old >> ${LOG_FILE} 2>&1
mv /usr/local/bin/bitcoincash-cli /usr/local/bin/bitcoin-cli-old >> ${LOG_FILE} 2>&1
cp /tmp/bitcoin-abc-0.20.2/bin/bitcoind /usr/local/bin/bitcoincashd >> ${LOG_FILE} 2>&1
cp /tmp/bitcoin-abc-0.20.2/bin/bitcoin-cli /usr/local/bin/bitcoincash-cli >> ${LOG_FILE} 2>&1
rm -r /tmp/bitcoin-abc-0.20.2 >> ${LOG_FILE} 2>&1
rm /tmp/bitcoincash.tar.gz >> ${LOG_FILE} 2>&1

sed -i 's/\<connections\>/maxconnections/g' /mnt/blockchains/bitcoincash/bitcoincash.conf >> ${LOG_FILE} 2>&1

supervisorctl start bitcoincash >> ${LOG_FILE} 2>&1

echo "Bitcoin Cash is updated."
echo
