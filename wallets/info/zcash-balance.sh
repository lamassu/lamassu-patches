#!/usr/bin/env bash

if [ $(dpkg-query -W -f='${Status}' jq 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  DEBIAN_FRONTEND=noninteractive apt-get install -y jq > /dev/null 2>&1;
fi

supervisorctl stop zcash

if grep -q "allowdeprecated=getnewaddress" /mnt/blockchains/zcash/zcash.conf
then
    echo "allowdeprecated=getnewaddress already defined, skipping..."
else
    echo "Setting 'allowdeprecated=getnewaddress' in config file..."
    echo -e "\nallowdeprecated=getnewaddress" >> /mnt/blockchains/zcash/zcash.conf
fi
echo

if grep -q "allowdeprecated=z_listaddresses" /mnt/blockchains/zcash/zcash.conf
then
    echo "allowdeprecated=z_listaddresses already defined, skipping..."
else
    echo "Setting 'allowdeprecated=z_listaddresses' in config file..."
    echo -e "\nallowdeprecated=z_listaddresses" >> /mnt/blockchains/zcash/zcash.conf
fi
echo

if grep -q "allowdeprecated=z_getbalance" /mnt/blockchains/zcash/zcash.conf
then
    echo "allowdeprecated=z_getbalance already defined, skipping..."
else
    echo "Setting 'allowdeprecated=z_getbalance' in config file..."
    echo -e "\nallowdeprecated=z_getbalance" >> /mnt/blockchains/zcash/zcash.conf
fi
echo

supervisorctl start zcash

echo
echo "Waiting for zcashd to start. This will take 20 seconds..."
sleep 20s

echo
echo "Here are your addresses and balances:"
echo
paste <(zcash-cli -conf=/mnt/blockchains/zcash/zcash.conf z_listaddresses |  jq -r "to_entries|map(\"\(.value|tostring)\")|.[]") <(zcash-cli -conf=/mnt/blockchains/zcash/zcash.conf z_listaddresses |  jq -r "to_entries|map(\"\(.value|tostring)\")|.[]" | xargs -n1 zcash-cli -conf=/mnt/blockchains/zcash/zcash.conf z_getbalance) | column -s $'\t' -t
echo
