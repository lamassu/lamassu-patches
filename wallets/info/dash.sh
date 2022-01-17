#!/usr/bin/env bash

if [ $(dpkg-query -W -f='${Status}' jq 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  DEBIAN_FRONTEND=noninteractive apt-get install -y jq > /dev/null 2>&1;
fi

echo
echo "Current dashd status:"
supervisorctl status dash
echo
echo "Current dashd release:"
dash-cli --version | sed -n '1 p'
echo
echo "Total blocks synchronised:"
dash-cli -conf=/mnt/blockchains/dash/dash.conf getblockcount
echo
echo "Known Dash block height:"
dash-cli -conf=/mnt/blockchains/dash/dash.conf getblockchaininfo | jq -r '.headers'
echo
