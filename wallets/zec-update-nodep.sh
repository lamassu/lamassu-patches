#!/bin/bash
set -e

export LOG_FILE=/tmp/zec-update.$(date +"%Y%m%d").log

echo
echo "Updating your Zcash wallet. This may take a minute."
supervisorctl stop zcash >> ${LOG_FILE} 2>&1
echo

echo "Downloading Zcash v4.4.1..."
curl -#Lo /tmp/zcash.tar.gz https://z.cash/downloads/zcash-4.4.1-linux64-debian-stretch.tar.gz >> ${LOG_FILE} 2>&1
tar -xzf /tmp/zcash.tar.gz -C /tmp/ >> ${LOG_FILE} 2>&1
echo

echo "Updating wallet..."
cp /tmp/zcash-4.4.1/bin/* /usr/local/bin/ >> ${LOG_FILE} 2>&1
rm -r /tmp/zcash-4.4.1 >> ${LOG_FILE} 2>&1
rm /tmp/zcash.tar.gz >> ${LOG_FILE} 2>&1
echo

echo "Starting wallet..."
supervisorctl start zcash >> ${LOG_FILE} 2>&1
echo

echo "Zcash is updated."
echo
