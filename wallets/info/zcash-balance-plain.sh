#!/usr/bin/env bash

echo
echo "Here are your addresses and balances:"
echo
paste <(zcash-cli -conf=/mnt/blockchains/zcash/zcash.conf z_listaddresses |  jq -r "to_entries|map(\"\(.value|tostring)\")|.[]") <(zcash-cli -conf=/mnt/blockchains/zcash/zcash.conf z_listaddresses |  jq -r "to_entries|map(\"\(.value|tostring)\")|.[]" | xargs -n1 zcash-cli -conf=/mnt/blockchains/zcash/zcash.conf getbalance) | column -s $'\t' -t
echo
