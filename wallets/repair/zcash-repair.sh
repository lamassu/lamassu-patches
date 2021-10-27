#!/bin/bash
set -e

d=$(date -u +"%Y-%m-%d")
export LOG_FILE=/tmp/zcash-update.$d.log

echo
echo 'Stopping Zcash...'
supervisorctl stop zcash >> ${LOG_FILE} 2>&1

echo
echo 'Clearing the database, chainstate, and blocks...'
cd /mnt/blockchains/zcash >> ${LOG_FILE} 2>&1
mkdir -p empty >> ${LOG_FILE} 2>&1
rsync -a --delete empty/ blocks/ >> ${LOG_FILE} 2>&1
rsync -a --delete empty/ chainstate/ >> ${LOG_FILE} 2>&1
rsync -a --delete empty/ database/ >> ${LOG_FILE} 2>&1
rm banlist.dat
rm peers.dat

echo
echo 'Updating Zcash...'
curl -#Lo /tmp/zcash.tar.gz https://z.cash/downloads/zcash-4.5.1-1-linux64-debian-stretch.tar.gz >> ${LOG_FILE} 2>&1
tar -xzf /tmp/zcash.tar.gz -C /tmp/ >> ${LOG_FILE} 2>&1
cp /tmp/zcash-4.5.1-1/bin/* /usr/local/bin/ >> ${LOG_FILE} 2>&1
rm -r /tmp/zcash-4.5.1-1 >> ${LOG_FILE} 2>&1
rm /tmp/zcash.tar.gz >> ${LOG_FILE} 2>&1

echo
echo 'Clearing Zcash logs...'
mv /var/log/supervisor/zcash.err.log /var/log/supervisor/zcash.err.log-$d >> ${LOG_FILE} 2>&1
mv /var/log/supervisor/zcash.out.log /var/log/supervisor/zcash.out.log-$d >> ${LOG_FILE} 2>&1

echo
echo "Resetting Zcash's supervisor configuration..."
curl -#o /etc/supervisor/conf.d/zcash.conf https://raw.githubusercontent.com/lamassu/lamassu-patches/master/wallets/repair/orig/zcash.conf >> ${LOG_FILE} 2>&1
supervisorctl reread >> ${LOG_FILE} 2>&1

echo
echo 'Starting Zcash...'
supervisorctl start zcash >> ${LOG_FILE} 2>&1

echo
echo 'Done!'
echo
