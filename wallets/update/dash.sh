#!/bin/bash
set -e

export LOG_FILE=/tmp/dash-update.$(date +"%Y%m%d").log

echo
echo "Updating Dash Core. This may take a minute."

echo
echo "Downloading Dash Core v18.1.0..."
sourceHash=$'d89c2afd78183f3ee815adcccdff02098be0c982633889e7b1e9c9656fbef219'
curl -#Lo /tmp/dash.tar.gz https://github.com/dashpay/dash/releases/download/v18.1.0/dashcore-18.1.0-x86_64-linux-gnu.tar.gz >> ${LOG_FILE} 2>&1
hash=$(sha256sum /tmp/dash.tar.gz | awk '{print $1}' | sed 's/ *$//g')

if [ $hash != $sourceHash ] ; then
        echo 'Package signature do not match!'
        exit 1
fi

supervisorctl stop dash >> ${LOG_FILE} 2>&1
tar -xzf /tmp/dash.tar.gz -C /tmp/ >> ${LOG_FILE} 2>&1
echo

echo "Updating..."
cp /tmp/dashcore-18.1.0/bin/* /usr/local/bin/ >> ${LOG_FILE} 2>&1
rm -r /tmp/dashcore-18.1.0 >> ${LOG_FILE} 2>&1
rm /tmp/dash.tar.gz >> ${LOG_FILE} 2>&1

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

echo "Starting wallet..."
supervisorctl start dash >> ${LOG_FILE} 2>&1
echo

echo "Dash Core is updated."
echo
