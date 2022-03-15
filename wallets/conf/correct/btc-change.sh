#!/bin/bash
set -e

sed -i 's/rpcport=8333changetype=bech32/rpcport=8333\nchangetype=bech32/g' /mnt/blockchains/bitcoin/bitcoin.conf
supervisorctl restart bitcoin &>/dev/null

echo
echo "Done."
echo
