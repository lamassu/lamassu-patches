#!/bin/bash
set -e

d=$(date -u "+%Y%m%d")
export LOG_FILE=/tmp/dash-update.$d.log

echo
echo 'Stopping Dash...'
supervisorctl stop dash >> ${LOG_FILE} 2>&1

echo
echo 'Clearing the database, chainstate, and blocks...'
cd /mnt/blockchains/dash >> ${LOG_FILE} 2>&1
mkdir empty-$d >> ${LOG_FILE} 2>&1
rsync -a --delete empty-$d/ database/ >> ${LOG_FILE} 2>&1
rsync -a --delete empty-$d/ chainstate/ >> ${LOG_FILE} 2>&1
rsync -a --delete empty-$d/ blocks/ >> ${LOG_FILE} 2>&1

echo
echo 'Updating Dash...'
curl -#Lo /tmp/dash.tar.gz https://github.com/dashpay/dash/releases/download/v0.15.0.0/dashcore-0.15.0.0-x86_64-linux-gnu.tar.gz >> ${LOG_FILE} 2>&1
tar -xzf /tmp/dash.tar.gz -C /tmp/ >> ${LOG_FILE} 2>&1
mv /usr/local/bin/dashd /usr/local/bin/dashd-old >> ${LOG_FILE} 2>&1
mv /usr/local/bin/dash-cli /usr/local/bin/dash-cli-old >> ${LOG_FILE} 2>&1
cp /tmp/dashcore-0.15.0/bin/dashd /usr/local/bin/dashd >> ${LOG_FILE} 2>&1
cp /tmp/dashcore-0.15.0/bin/dash-cli /usr/local/bin/dash-cli >> ${LOG_FILE} 2>&1
rm -r /tmp/dashcore-0.15.0 >> ${LOG_FILE} 2>&1
rm /tmp/dash.tar.gz >> ${LOG_FILE} 2>&1

echo
echo 'Clearing Dash logs...'
mv /var/log/supervisor/dash.err.log /var/log/supervisor/dash.err.log-$d >> ${LOG_FILE} 2>&1
mv /var/log/supervisor/dash.out.log /var/log/supervisor/dash.out.log-$d >> ${LOG_FILE} 2>&1

echo
echo "Setting Dash's supervisor configuration..."
curl -#o /etc/supervisor/conf.d/dash.conf https://raw.githubusercontent.com/lamassu/lamassu-patches/master/wallets/repair/orig/dash.conf >> ${LOG_FILE} 2>&1
supervisorctl reread >> ${LOG_FILE} 2>&1

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
echo 'Starting Dash...'
supervisorctl start dash >> ${LOG_FILE} 2>&1

echo
echo 'Done!'
echo
