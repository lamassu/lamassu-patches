#!/usr/bin/env bash

if [ $(dpkg-query -W -f='${Status}' jq 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  DEBIAN_FRONTEND=noninteractive apt-get install -y jq 2>/dev/null;
fi

echo
echo "Current zcashd status:"
supervisorctl status zcash
echo
echo "Current zcashd release:"
zcash-cli --version | sed -n '1 p'
echo
echo "Current synchronised blocks:"
zcash-cli -conf=/mnt/blockchains/zcash/zcash.conf getblockcount
echo
echo "Current zcash blockheight:"
zcash-cli -conf=/mnt/blockchains/zcash/zcash.conf getblockchaininfo | jq -r '.headers'
echo
