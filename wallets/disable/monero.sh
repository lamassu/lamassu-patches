#!/bin/bash
set -e

d=$(date -u "+%s")

echo
echo 'Stopping Monero...'
supervisorctl stop monero monero-wallet &>/dev/null

echo
echo 'Clearing the Monero database...'
cd /mnt/blockchains/monero
mkdir empty-$d
rsync -a --delete empty-$d/ lmdb/

echo
echo "Disabling Monero..."
cd /etc/supervisor/conf.d
mkdir -p disabled
mv monero.conf disabled/
mv monero-wallet.conf disabled/
supervisorctl reread &>/dev/null
supervisorctl update monero monero-wallet &>/dev/null

supervisorctl stop all &>/dev/null
supervisorctl start all &>/dev/null

echo
echo "Done."
echo
