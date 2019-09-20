#!/bin/bash
set -e

export LOG_FILE=/tmp/dash-update.$(date +"%Y%m%d").log

echo "Updating Dash Core. This may take a minute."
supervisorctl stop dash >> ${LOG_FILE} 2>&1
echo
echo "Downloading..."
curl -#Lo /tmp/dash.tar.gz https://github.com/dashpay/dash/releases/download/v0.14.0.3/dashcore-0.14.0.3-x86_64-linux-gnu.tar.gz >> ${LOG_FILE} 2>&1
tar -xzf /tmp/dash.tar.gz -C /tmp/ >> ${LOG_FILE} 2>&1
echo
echo "Updating..."
mv /usr/local/bin/dashd /usr/local/bin/dashd-old >> ${LOG_FILE} 2>&1
mv /usr/local/bin/dash-cli /usr/local/bin/dash-cli-old >> ${LOG_FILE} 2>&1
mv /usr/local/bin/dash-tx /usr/local/bin/dash-tx-old >> ${LOG_FILE} 2>&1
mv /usr/local/bin/dash-qt /usr/local/bin/dash-qt-old >> ${LOG_FILE} 2>&1
cp /tmp/dashcore-0.14.0/bin/* /usr/local/bin/ >> ${LOG_FILE} 2>&1
rm -r /tmp/dashcore-0.14.0 >> ${LOG_FILE} 2>&1
rm /tmp/dash.tar.gz >> ${LOG_FILE} 2>&1
supervisorctl start dash >> ${LOG_FILE} 2>&1
echo
echo "Dash Core is updated."
echo
