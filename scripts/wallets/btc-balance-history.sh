#!/bin/bash

bitcoin-cli -conf=/mnt/blockchains/bitcoin/bitcoin.conf listtransactions "*" 1000000000 0 > /tmp/transactions.log 
cat /tmp/transactions.log | grep amount | sed s:"    \"amount\"\: ":: | tr -d \\n | tr ',' ' ' | awk '{for (i=1; i<=NF; i++) {c+=$i; print c}}' > /tmp/balances.log
cat /tmp/transactions.log | grep blocktime | sed s:"    \"blocktime\"\: ":: | tr -d \\n | tr ',' '\n' | perl -pe 'use POSIX qw(strftime); s/^(\d+)/strftime "%F %H:%M:%S", localtime($1)/e' > /tmp/blocktimes.log
cat /tmp/transactions.log | grep txid | sed s:"    \"txid\"\: ":: | tr -d \\n | tr ',' '\n'  > /tmp/txid.log
pr -J -m -t /tmp/balances.log /tmp/blocktimes.log /tmp/txid.log > balancehistory.txt
rm /tmp/balances.log /tmp/blocktimes.log /tmp/txid.log
cat balancehistory.txt
