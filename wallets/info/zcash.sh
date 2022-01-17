#!/usr/bin/env bash

if [ $(dpkg-query -W -f='${Status}' jq 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  DEBIAN_FRONTEND=noninteractive apt-get install -y jq > /dev/null 2>&1;
fi

echo
echo "Current zcashd status:"
supervisorctl status zcash
echo
echo "Current zcashd release:"
zcash-cli --version | sed -n '1 p'
echo
echo "Total blocks synchronised:"
zcash-cli -conf=/mnt/blockchains/zcash/zcash.conf getblockcount
echo
echo "Known Zcash block height:"
zcash-cli -conf=/mnt/blockchains/zcash/zcash.conf getblockchaininfo | jq -r '.headers'
echo
