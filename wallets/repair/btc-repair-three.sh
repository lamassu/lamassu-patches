#!/bin/bash

d=$(date -u "+%s")
export LOG_FILE=/tmp/bitcoin-update.$d.log

echo
echo 'Stopping bitcoind...'
supervisorctl stop bitcoin >> ${LOG_FILE} 2>&1
sleep 5s
killall bitcoind >> ${LOG_FILE} 2>&1

echo
echo 'Clearing another set of the database, chainstate, and blocks...'
cd /root/.bitcoin >> ${LOG_FILE} 2>&1
mkdir -p empty-$d >> ${LOG_FILE} 2>&1
rsync -a --delete empty-$d/ blocks/ >> ${LOG_FILE} 2>&1
rsync -a --delete empty-$d/ chainstate/ >> ${LOG_FILE} 2>&1

echo
echo 'Clearing Bitcoin logs...'
mv /var/log/supervisor/bitcoin.err.log /var/log/supervisor/bitcoin.err.log-$d >> ${LOG_FILE} 2>&1
mv /var/log/supervisor/bitcoin.out.log /var/log/supervisor/bitcoin.out.log-$d >> ${LOG_FILE} 2>&1

echo
echo "Setting Bitcoin to reindex..."
curl -#o /etc/supervisor/conf.d/bitcoin.conf https://raw.githubusercontent.com/lamassu/lamassu-patches/master/wallets/repair/orig/bitcoin-reindex.conf >> ${LOG_FILE} 2>&1
supervisorctl update bitcoin >> ${LOG_FILE} 2>&1

echo
echo 'Restarting Bitcoin...'
sleep 5s
curl -#o /etc/supervisor/conf.d/bitcoin.conf https://raw.githubusercontent.com/lamassu/lamassu-patches/master/wallets/repair/orig/bitcoin.conf >> ${LOG_FILE} 2>&1
sleep 5s
supervisorctl update bitcoin >> ${LOG_FILE} 2>&1

echo
echo 'Done!'
echo
