#!/usr/bin/env bash

echo
echo "Current zcashd status:"
supervisorctl status zcash
echo
echo "Current zcashd release:"
zcash-cli --version | sed -n '1 p'
echo
echo "Current zcashd blockcount:"
zcash-cli -conf=/mnt/blockchains/zcash/zcash.conf getblockcount
echo
