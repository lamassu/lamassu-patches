#!/usr/bin/env bash

export LOG_FILE=/tmp/script.$(date +"%Y%m%d").support.log

echo
echo "Updating nodes, disabling zcashd, and restarting the server. This may take a minute..."
echo

supervisorctl stop all >> ${LOG_FILE} 2>&1

# update zcashd
curl -#Lo /tmp/zcash.tar.gz https://z.cash/downloads/zcash-4.6.0-1-linux64-debian-stretch.tar.gz >> ${LOG_FILE} 2>&1
tar -xzf /tmp/zcash.tar.gz -C /tmp/ >> ${LOG_FILE} 2>&1
cp /tmp/zcash-4.6.0-1/bin/* /usr/local/bin/ >> ${LOG_FILE} 2>&1
rm -r /tmp/zcash-4.6.0-1 >> ${LOG_FILE} 2>&1
rm /tmp/zcash.tar.gz >> ${LOG_FILE} 2>&1

# update bitcoind
curl -#o /tmp/bitcoin.tar.gz https://bitcoincore.org/bin/bitcoin-core-22.0/bitcoin-22.0-x86_64-linux-gnu.tar.gz >> ${LOG_FILE} 2>&1
tar -xzf /tmp/bitcoin.tar.gz -C /tmp/ >> ${LOG_FILE} 2>&1
cp /tmp/bitcoin-22.0/bin/* /usr/local/bin/ >> ${LOG_FILE} 2>&1
rm -r /tmp/bitcoin-22.0 >> ${LOG_FILE} 2>&1
rm /tmp/bitcoin.tar.gz >> ${LOG_FILE} 2>&1

if grep -q "changetype=" /mnt/blockchains/bitcoin/bitcoin.conf
then
    echo "changetype already defined, skipping..." >> ${LOG_FILE} 2>&1
else
    echo "Enabling bech32 change addresses in config file..." >> ${LOG_FILE} 2>&1
    echo -e "\nchangetype=bech32" >> /mnt/blockchains/bitcoin/bitcoin.conf
fi

# disable zcashd
mkdir -p /etc/supervisor/conf.d/disabled/ >> ${LOG_FILE} 2>&1
mv /etc/supervisor/conf.d/zcash.conf /etc/supervisor/conf.d/disabled/zcash.conf >> ${LOG_FILE} 2>&1
supervisorctl reread >> ${LOG_FILE} 2>&1
supervisorctl update zcash >> ${LOG_FILE} 2>&1

# reboot server
sleep 5s >> ${LOG_FILE} 2>&1
echo "Done! Rebooting the server. Please wait a couple minutes, then you may log back into your server with SSH."
echo
shutdown -r now >> ${LOG_FILE} 2>&1
