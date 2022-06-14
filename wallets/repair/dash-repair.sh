#!/bin/bash
set -e

d=$(date -u "+%s")
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
rsync -a --delete empty-$d/ evodb/ >> ${LOG_FILE} 2>&1

echo
echo 'Updating Dash...'
curl -#Lo /tmp/dash.tar.gz https://github.com/dashpay/dash/releases/download/v0.17.0.3/dashcore-0.17.0.3-x86_64-linux-gnu.tar.gz >> ${LOG_FILE} 2>&1
tar -xzf /tmp/dash.tar.gz -C /tmp/ >> ${LOG_FILE} 2>&1
mv /usr/local/bin/dashd /usr/local/bin/dashd-old >> ${LOG_FILE} 2>&1
mv /usr/local/bin/dash-cli /usr/local/bin/dash-cli-old >> ${LOG_FILE} 2>&1
cp /tmp/dashcore-0.17.0/bin/dashd /usr/local/bin/dashd >> ${LOG_FILE} 2>&1
cp /tmp/dashcore-0.17.0/bin/dash-cli /usr/local/bin/dash-cli >> ${LOG_FILE} 2>&1
rm -r /tmp/dashcore-0.17.0 >> ${LOG_FILE} 2>&1
rm /tmp/dash.tar.gz >> ${LOG_FILE} 2>&1

echo
echo 'Clearing Dash logs...'
mv /var/log/supervisor/dash.err.log /var/log/supervisor/dash.err.log-$d >> ${LOG_FILE} 2>&1
mv /var/log/supervisor/dash.out.log /var/log/supervisor/dash.out.log-$d >> ${LOG_FILE} 2>&1

echo
if grep -q "enableprivatesend=" /mnt/blockchains/dash/dash.conf; then
    echo "Switching from 'PrivateSend' to 'CoinJoin'..."
    sed -i 's/enableprivatesend/enablecoinjoin/g' /mnt/blockchains/dash/dash.conf
elif grep -q "enablecoinjoin=" /mnt/blockchains/dash/dash.conf; then
    echo "enablecoinjoin already defined, skipping..."
else
    echo "Enabling CoinJoin in config file..."
    echo -e "\nenablecoinjoin=1" >> /mnt/blockchains/dash/dash.conf
fi

if grep -q "privatesendautostart=" /mnt/blockchains/dash/dash.conf; then
    echo "Switching from 'PrivateSend' to 'CoinJoin'..."
    sed -i 's/privatesendautostart/coinjoinautostart/g' /mnt/blockchains/dash/dash.conf
elif grep -q "coinjoinautostart=" /mnt/blockchains/dash/dash.conf; then
    echo "coinjoinautostart already defined, skipping..."
else
    echo "Enabling CoinJoin AutoStart in config file..."
    echo -e "\ncoinjoinautostart=1" >> /mnt/blockchains/dash/dash.conf
fi

if grep -q "litemode=" /mnt/blockchains/dash/dash.conf; then
    echo "Switching from 'LiteMode' to 'DisableGovernance'..."
    sed -i 's/litemode/disablegovernance/g' /mnt/blockchains/dash/dash.conf
else
    echo "disablegovernance already defined, skipping..."
fi
echo

echo
echo "Setting Dash's supervisor configuration..."
curl -#o /etc/supervisor/conf.d/dash.conf https://raw.githubusercontent.com/lamassu/lamassu-patches/master/wallets/repair/orig/dash-reindex.conf >> ${LOG_FILE} 2>&1

echo
echo 'Starting Dash...'
supervisorctl update dash >> ${LOG_FILE} 2>&1
curl -#o /etc/supervisor/conf.d/dash.conf https://raw.githubusercontent.com/lamassu/lamassu-patches/master/wallets/repair/orig/dash.conf >> ${LOG_FILE} 2>&1

echo
echo 'Done!'
echo
