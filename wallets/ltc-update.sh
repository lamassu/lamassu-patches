#!/bin/bash
set -e

export LOG_FILE=/tmp/ltc-update.$(date +"%Y%m%d").log

echo
echo "Updating Litecoin Core. This may take a minute."
supervisorctl stop litecoin >> ${LOG_FILE} 2>&1
echo
echo "Downloading..."
curl -#o /tmp/litecoin.tar.gz https://download.litecoin.org/litecoin-0.16.3/linux/litecoin-0.16.3-x86_64-linux-gnu.tar.gz >> ${LOG_FILE} 2>&1
tar -xzf /tmp/litecoin.tar.gz -C /tmp/ >> ${LOG_FILE} 2>&1
echo
echo "Updating..."
mv /usr/local/bin/litecoind /usr/local/bin/litecoind-old >> ${LOG_FILE} 2>&1
mv /usr/local/bin/litecoin-cli /usr/local/bin/litecoin-cli-old >> ${LOG_FILE} 2>&1
mv /usr/local/bin/litecoin-tx /usr/local/bin/litecoin-tx-old >> ${LOG_FILE} 2>&1
mv /usr/local/bin/litecoin-qt /usr/local/bin/litecoin-qt-old >> ${LOG_FILE} 2>&1
cp /tmp/litecoin-0.16.3/bin/* /usr/local/bin/ >> ${LOG_FILE} 2>&1
rm -r /tmp/litecoin-0.16.3 >> ${LOG_FILE} 2>&1
rm /tmp/litecoin.tar.gz >> ${LOG_FILE} 2>&1
supervisorctl start litecoin >> ${LOG_FILE} 2>&1
echo
echo "Litecoin Core is updated."
echo
