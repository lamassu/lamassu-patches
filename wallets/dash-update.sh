#!/bin/bash
set -e

export LOG_FILE=/tmp/dash-update.$(date +"%Y%m%d").log

echo
echo "Updating Dash Core. This may take a minute."
supervisorctl stop dash >> ${LOG_FILE} 2>&1
echo
echo "Downloading Dash Core v0.15.0..."
curl -#Lo /tmp/dash.tar.gz https://github.com/dashpay/dash/releases/download/v0.15.0.0/dashcore-0.15.0.0-x86_64-linux-gnu.tar.gz >> ${LOG_FILE} 2>&1
tar -xzf /tmp/dash.tar.gz -C /tmp/ >> ${LOG_FILE} 2>&1
echo
echo "Updating..."
mv /usr/local/bin/dashd /usr/local/bin/dashd-old >> ${LOG_FILE} 2>&1
mv /usr/local/bin/dash-cli /usr/local/bin/dash-cli-old >> ${LOG_FILE} 2>&1
cp /tmp/dashcore-0.15.0/bin/dashd /usr/local/bin/dashd >> ${LOG_FILE} 2>&1
cp /tmp/dashcore-0.15.0/bin/dash-cli /usr/local/bin/dash-cli >> ${LOG_FILE} 2>&1
rm -r /tmp/dashcore-0.15.0 >> ${LOG_FILE} 2>&1
rm /tmp/dash.tar.gz >> ${LOG_FILE} 2>&1
supervisorctl start dash >> ${LOG_FILE} 2>&1
echo
echo "Dash Core is updated."
echo
