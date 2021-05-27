#!/bin/bash
set -e

export LOG_FILE=/tmp/dash-update.$(date +"%Y%m%d").log

echo
echo "Updating Dash Core. This may take a minute."
supervisorctl stop dash >> ${LOG_FILE} 2>&1

echo
echo "Downloading Dash Core v0.17.0.2..."
curl -#Lo /tmp/dash.tar.gz https://github.com/dashpay/dash/releases/download/v0.17.0.2/dashcore-0.17.0.2-x86_64-linux-gnu.tar.gz >> ${LOG_FILE} 2>&1
tar -xzf /tmp/dash.tar.gz -C /tmp/ >> ${LOG_FILE} 2>&1

echo
echo "Updating..."
cp /tmp/dashcore-0.17.0/bin/* /usr/local/bin/ >> ${LOG_FILE} 2>&1
rm -r /tmp/dashcore-0.17.0 >> ${LOG_FILE} 2>&1
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

echo "Starting wallet..."
supervisorctl start dash >> ${LOG_FILE} 2>&1
echo

echo "Dash Core is updated."
echo
