#!/usr/bin/env bash

if [ $(dpkg-query -W -f='${Status}' jq 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  DEBIAN_FRONTEND=noninteractive apt-get install -y jq > /dev/null 2>&1;
fi

echo
echo "Current litecoind status:"
supervisorctl status litecoin
echo
echo "Current litecoind release:"
litecoin-cli --version
echo
echo "Total blocks synchronised:"
litecoin-cli -conf=/mnt/blockchains/litecoin/litecoin.conf getblockcount
echo
echo "Known Litecoin block height:"
litecoin-cli -conf=/mnt/blockchains/litecoin/litecoin.conf getblockchaininfo | jq -r '.headers'
echo
