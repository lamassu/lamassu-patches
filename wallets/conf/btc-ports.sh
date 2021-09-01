#!/bin/bash
set -e

BTC_CONF=/mnt/blockchains/bitcoin/bitcoin.conf

echo
echo "Deploying the patch. This will take about 10 seconds, after which, your server will restart."
echo

if grep -xq "bind=.*" $BTC_CONF; then
    echo "bitcoind port already defined, skipping..."
    echo
else
    echo -e "bind=0.0.0.0:8332" >> $BTC_CONF
fi

if grep -xq "rpcport=.*" $BTC_CONF; then
    echo "bitcoind RPC port already defined, skipping..."
    echo
else
    echo -e "rpcport=8333" >> $BTC_CONF
fi

supervisorctl stop all &>/dev/null
sleep 10s &>/dev/null

echo "Done!"
echo
echo "Going down for a restart. Please wait 5 minutes, then log into your server again."
echo

shutdown -r now &>/dev/null
