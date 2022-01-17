#!/usr/bin/env bash

if [ $(dpkg-query -W -f='${Status}' jq 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  DEBIAN_FRONTEND=noninteractive apt-get install -y jq > /dev/null 2>&1;
fi

echo
echo "Current bitcoincashd status:"
supervisorctl status bitcoincash
echo
echo "Current bitcoincashd release:"
bitcoincash-cli --version | sed -n '1 p'
echo
echo "Total blocks synchronised:"
bitcoincash-cli -conf=/mnt/blockchains/bitcoincash/bitcoincash.conf getblockcount
echo
echo "Known Bitcoin Cash block height:"
bitcoincash-cli -conf=/mnt/blockchains/bitcoincash/bitcoincash.conf getblockchaininfo | jq -r '.headers'
echo
