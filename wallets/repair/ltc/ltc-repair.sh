#!/bin/bash
set -e

d=$(date -u "+%Y%m%d")

echo
echo 'Stopping Litecoin...'
supervisorctl stop litecoin &>/dev/null

echo 'Clearing the database, chainstate, and blocks...'
cd /mnt/blockchains/litecoin
mkdir empty-$d
rsync -a --delete empty-$d/ database/
rsync -a --delete empty-$d/ chainstate/
rsync -a --delete empty-$d/ blocks/

echo 'Updating Litecoin...'
curl -#Lo /tmp/litecoin.tar.gz https://github.com/litecoin-project/litecoin/releases/download/v0.21.2.1/litecoin-0.21.2.1-x86_64-linux-gnu.tar.gz &>/dev/null
tar -xzf /tmp/litecoin.tar.gz -C /tmp/ &>/dev/null
cp /tmp/litecoin-0.21.2.1/bin/* /usr/local/bin/ &>/dev/null
rm -r /tmp/litecoin-0.21.2.1 &>/dev/null
rm /tmp/litecoin.tar.gz &>/dev/null

echo 'Clearing Litecoin logs...'
set +e
mv /var/log/supervisor/litecoin.err.log /var/log/supervisor/litecoin-old.err.log
mv /var/log/supervisor/litecoin.out.log /var/log/supervisor/litecoin-old.out.log
set -e

echo "Resetting Litecoin configurations..."
curl -#o /etc/supervisor/conf.d/litecoin.conf https://raw.githubusercontent.com/lamassu/lamassu-patches/master/wallets/repair/ltc/litecoin.conf &>/dev/null
supervisorctl reread &>/dev/null
supervisorctl update litecoin &>/dev/null

echo 'Starting Litecoin...'
supervisorctl start litecoin &>/dev/null
supervisorctl restart lamassu-server lamassu-admin-server &>/dev/null

echo 'Done!'
echo
