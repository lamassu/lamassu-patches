#!/bin/bash
set -e

export LOG_FILE=/tmp/ltc-update.$(date +"%Y%m%d").log

echo
echo "Updating Litecoin Core. This may take a minute."
supervisorctl stop litecoin >> ${LOG_FILE} 2>&1
echo

echo "Downloading v0.18.1..."
curl -#o /tmp/litecoin.tar.gz https://download.litecoin.org/litecoin-0.18.1/linux/litecoin-0.18.1-x86_64-linux-gnu.tar.gz >> ${LOG_FILE} 2>&1
tar -xzf /tmp/litecoin.tar.gz -C /tmp/ >> ${LOG_FILE} 2>&1
echo

echo "Updating wallet..."
mv /usr/local/bin/litecoind /usr/local/bin/litecoind-old >> ${LOG_FILE} 2>&1
mv /usr/local/bin/litecoin-cli /usr/local/bin/litecoin-cli-old >> ${LOG_FILE} 2>&1
mv /usr/local/bin/litecoin-tx /usr/local/bin/litecoin-tx-old >> ${LOG_FILE} 2>&1
mv /usr/local/bin/litecoin-qt /usr/local/bin/litecoin-qt-old >> ${LOG_FILE} 2>&1
cp /tmp/litecoin-0.18.1/bin/* /usr/local/bin/ >> ${LOG_FILE} 2>&1
rm -r /tmp/litecoin-0.18.1 >> ${LOG_FILE} 2>&1
rm /tmp/litecoin.tar.gz >> ${LOG_FILE} 2>&1
echo

echo "Starting wallet..."
supervisorctl start litecoin >> ${LOG_FILE} 2>&1
echo

echo "Litecoin Core is updated."
echo
