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
curl -#o /tmp/litecoin.tar.gz https://download.litecoin.org/litecoin-0.21.2.1/linux/litecoin-0.21.2.1-x86_64-linux-gnu.tar.gz >> ${LOG_FILE} 2>&1
tar -xzf /tmp/litecoin.tar.gz -C /tmp/ >> ${LOG_FILE} 2>&1
cp /tmp/litecoin-0.21.2.1/bin/* /usr/local/bin/ >> ${LOG_FILE} 2>&1
rm -r /tmp/litecoin-0.21.2.1 >> ${LOG_FILE} 2>&1
rm /tmp/litecoin.tar.gz >> ${LOG_FILE} 2>&1

echo 'Clearing Litecoin logs...'
mv /var/log/supervisor/litecoin.err.log /var/log/supervisor/litecoin-old.err.log
mv /var/log/supervisor/litecoin.out.log /var/log/supervisor/litecoin-old.out.log

echo "Resetting Litecoin configurations..."
curl -#o /etc/supervisor/conf.d/litecoin.conf https://raw.githubusercontent.com/lamassu/lamassu-patches/master/wallets/repair/ltc/litecoin.conf >> ${LOG_FILE} 2>&1
supervisorctl reread litecoin >> ${LOG_FILE} 2>&1
supervisorctl update litecoin >> ${LOG_FILE} 2>&1

echo 'Starting Litecoin...'
supervisorctl start litecoin >> ${LOG_FILE} 2>&1
supervisorctl restart lamassu-server lamassu-admin-server >> ${LOG_FILE} 2>&1

echo 'Done!'
echo
