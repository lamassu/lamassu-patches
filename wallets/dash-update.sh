#!/bin/bash
set -e

export LOG_FILE=/tmp/dash-update.$(date +"%Y%m%d").log

echo
echo "Updating Dash Core. This may take a minute."
supervisorctl stop dash >> ${LOG_FILE} 2>&1

echo
echo "Downloading Dash Core v0.16.0.1..."
curl -#Lo /tmp/dash.tar.gz https://github.com/dashpay/dash/releases/download/v0.16.0.1/dashcore-0.16.0.1-x86_64-linux-gnu.tar.gz >> ${LOG_FILE} 2>&1
tar -xzf /tmp/dash.tar.gz -C /tmp/ >> ${LOG_FILE} 2>&1

echo
echo "Updating..."
mv /usr/local/bin/dashd /usr/local/bin/dashd-old >> ${LOG_FILE} 2>&1
mv /usr/local/bin/dash-cli /usr/local/bin/dash-cli-old >> ${LOG_FILE} 2>&1
cp /tmp/dashcore-0.16.0/bin/dashd /usr/local/bin/dashd >> ${LOG_FILE} 2>&1
cp /tmp/dashcore-0.16.0/bin/dash-cli /usr/local/bin/dash-cli >> ${LOG_FILE} 2>&1
rm -r /tmp/dashcore-0.16.0 >> ${LOG_FILE} 2>&1
rm /tmp/dash.tar.gz >> ${LOG_FILE} 2>&1

echo
if grep -xq "enableprivatesend=." /mnt/blockchains/dash/dash.conf
then
    echo "enableprivatesend already defined, skipping..."
else
    echo "Enabling PrivateSend in config file..."
    echo -e "enableprivatesend=1" >> /mnt/blockchains/dash/dash.conf
fi
if grep -xq "privatesendautostart=." /mnt/blockchains/dash/dash.conf
then
    echo "privatesendautostart already defined, skipping..."
else
    echo "Setting PrivateSend AutoStart in config file..."
    echo -e "privatesendautostart=1" >> /mnt/blockchains/dash/dash.conf
fi

echo
supervisorctl start dash >> ${LOG_FILE} 2>&1
echo "Dash Core is updated."
echo
