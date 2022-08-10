#!/bin/bash
set -e

d=$(date -u "+%s")

echo
echo "Stopping Zcash..."
supervisorctl stop zcash &>/dev/null

echo
echo "Clearing the Zcash database..."
cd /mnt/blockchains/zcash
mkdir empty-$d
rsync -a --delete empty-$d/ blocks/

echo
echo "Disabling Zcash..."
cd /etc/supervisor/conf.d
mkdir -p disabled
mv zcash.conf disabled/
supervisorctl reread &>/dev/null
supervisorctl update zcash &>/dev/null

supervisorctl stop all &>/dev/null
supervisorctl start all &>/dev/null

echo
echo "Done."
echo
