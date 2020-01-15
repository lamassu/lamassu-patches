#!/bin/bash
set -e

export LOG_FILE=/tmp/bch-update.$(date +"%Y%m%d").log

echo
echo "Updating Bitcoin Cash. This may take a minute..."
supervisorctl stop bitcoincash >> ${LOG_FILE} 2>&1

echo "Downloading..."
curl -#o $(npm root -g)/lamassu-server/lib/plugins/wallet/bitcoincashd/bitcoincashd.js https://raw.githubusercontent.com/naconner/lamassu-server/3a77d7697dedfd503db0c8c8dff7cec92bb9f139/lib/plugins/wallet/bitcoincashd/bitcoincashd.js >> ${LOG_FILE} 2>&1
curl -#o /tmp/bitcoincash.tar.gz https://download.bitcoinabc.org/0.20.5/linux/bitcoin-abc-0.20.5-x86_64-linux-gnu.tar.gz >> ${LOG_FILE} 2>&1
tar -xzf /tmp/bitcoincash.tar.gz -C /tmp/ >> ${LOG_FILE} 2>&1

echo "Updating..."
mv /usr/local/bin/bitcoincashd /usr/local/bin/bitcoincashd-old >> ${LOG_FILE} 2>&1
mv /usr/local/bin/bitcoincash-cli /usr/local/bin/bitcoin-cli-old >> ${LOG_FILE} 2>&1
cp /tmp/bitcoin-abc-0.20.5/bin/bitcoind /usr/local/bin/bitcoincashd >> ${LOG_FILE} 2>&1
cp /tmp/bitcoin-abc-0.20.5/bin/bitcoin-cli /usr/local/bin/bitcoincash-cli >> ${LOG_FILE} 2>&1
rm -r /tmp/bitcoin-abc-0.20.5 >> ${LOG_FILE} 2>&1
rm /tmp/bitcoincash.tar.gz >> ${LOG_FILE} 2>&1

sed -i 's/\<connections\>/maxconnections/g' /mnt/blockchains/bitcoincash/bitcoincash.conf >> ${LOG_FILE} 2>&1

supervisorctl start bitcoincash >> ${LOG_FILE} 2>&1
supervisorctl restart lamassu-server lamassu-admin-server >> ${LOG_FILE} 2>&1

echo "Bitcoin Cash is updated."
echo
