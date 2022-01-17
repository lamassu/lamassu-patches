#!/usr/bin/env bash

if [ $(dpkg-query -W -f='${Status}' jq 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  DEBIAN_FRONTEND=noninteractive apt-get install -y jq > /dev/null 2>&1;
fi

echo
echo "Current bitcoind status:"
supervisorctl status bitcoin
echo
echo "Current bitcoind release:"
bitcoin-cli --version | sed -n '1 p'
echo
echo "Total blocks synchronised:"
bitcoin-cli -conf=/mnt/blockchains/bitcoin/bitcoin.conf getblockcount
echo
echo "Known Bitcoin block height:"
bitcoin-cli -conf=/mnt/blockchains/bitcoin/bitcoin.conf getblockchaininfo | jq -r '.headers'
echo
