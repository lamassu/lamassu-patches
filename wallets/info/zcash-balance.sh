#!/usr/bin/env bash

if [ $(dpkg-query -W -f='${Status}' jq 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  DEBIAN_FRONTEND=noninteractive apt-get install -y jq > /dev/null 2>&1;
fi

echo
echo "Here are your addresses and balances:"
echo
paste <(zcash-cli -conf=/mnt/blockchains/zcash/zcash.conf z_listaddresses |  jq -r "to_entries|map(\"\(.value|tostring)\")|.[]") <(zcash-cli -conf=/mnt/blockchains/zcash/zcash.conf z_listaddresses |  jq -r "to_entries|map(\"\(.value|tostring)\")|.[]" | xargs -n1 zcash-cli -conf=/mnt/blockchains/zcash/zcash.conf z_getbalance) | column -s $'\t' -t
echo
