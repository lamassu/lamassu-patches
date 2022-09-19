#!/bin/bash
set -e

BTC_CONF=/mnt/blockchains/bitcoin/bitcoin.conf
BCH_CONF=/mnt/blockchains/bitcoincash/bitcoincash.conf

echo
echo "Deploying the patch. This will take about 10 seconds, after which, your server will restart."
echo

supervisorctl stop all &>/dev/null

## Bitcoin

if grep -xq "bind=.*" $BTC_CONF; then
    echo "bitcoind port already defined, skipping..."
else
    echo "Defining bitcoind port..."
    echo -e "bind=0.0.0.0:8332" >> $BTC_CONF
fi

if grep -xq "rpcport=.*" $BTC_CONF; then
    echo "bitcoind RPC port already defined, skipping..."
else
    echo "Defining bitcoind RPC port..."
    echo -e "rpcport=8333" >> $BTC_CONF
fi

if grep -q "listenonion=" $BTC_CONF
then
    echo "listenonion already defined, skipping..."
else
    echo "Setting 'listenonion=0' in config file..."
    echo -e "\nlistenonion=0" >> $BTC_CONF
fi

## Bitcoin Cash

if grep -q "listenonion=" $BCH_CONF
then
    echo "listenonion already defined, skipping..."
else
    echo "Setting 'listenonion=0' in config file..."
    echo -e "\nlistenonion=0" >> $BCH_CONF
fi

if grep -q "bind=0.0.0.0:8335" $BCH_CONF
then
    echo "bind port already updated, skipping..."
else
    echo "Updating bitcoincashd port..."
    sed -i 's/bind=0.0.0.0:8334/bind=0.0.0.0:8335/g' $BCH_CONF
fi

if grep -q "rpcport=8336" $BCH_CONF
then
    echo "rpc port already updated, skipping..."
else
    echo "Updating bitcoincashd RPC port..."
    sed -i 's/rpcport=8335/rpcport=8336/g' $BCH_CONF
fi

sleep 5s &>/dev/null

echo
echo "Done!"
echo
echo "Going down for a restart. Please wait 5 minutes, then log into your server again."
echo

shutdown -r now &>/dev/null
