#!/bin/bash
set -e

export LOG_FILE=/tmp/zec-update.$(date +"%Y%m%d").log

echo
echo "Updating your Zcash wallet. This may take a few minutes."
supervisorctl stop zcash >> ${LOG_FILE} 2>&1
echo
echo "Downloading Zcash v2.0.7-3..."
curl -#Lo /tmp/zcash.tar.gz https://z.cash/downloads/zcash-2.0.7-3-linux64-debian-jessie.tar.gz >> ${LOG_FILE} 2>&1
tar -xzf /tmp/zcash.tar.gz -C /tmp/ >> ${LOG_FILE} 2>&1
echo
echo "Updating..."
mv /usr/local/bin/zcashd /usr/local/bin/zcashd-old >> ${LOG_FILE} 2>&1
mv /usr/local/bin/zcash-cli /usr/local/bin/zcash-cli-old >> ${LOG_FILE} 2>&1
mv /usr/local/bin/zcash-tx /usr/local/bin/zcash-tx-old >> ${LOG_FILE} 2>&1
mv /usr/local/bin/zcash-fetch-params /usr/local/bin/zcash-fetch-params-old >> ${LOG_FILE} 2>&1
cp /tmp/zcash-2.0.7-3/bin/* /usr/local/bin/ >> ${LOG_FILE} 2>&1
rm -r /tmp/zcash-2.0.7-3 >> ${LOG_FILE} 2>&1
rm /tmp/zcash.tar.gz >> ${LOG_FILE} 2>&1
echo
echo "Downloading Sapling parameters, this will take a minute or two..."
zcash-fetch-params >> ${LOG_FILE} 2>&1
supervisorctl update zcash >> ${LOG_FILE} 2>&1
supervisorctl start zcash >> ${LOG_FILE} 2>&1
echo
echo "Zcash is updated and running."
echo
