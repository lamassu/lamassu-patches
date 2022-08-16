#!/bin/bash

SERVER_LOG_ARCHIVE=/tmp/ls-prof-log_$HOSTNAME.tar.bz2
HOST=165.227.82.206
USER='ftpuser'
REMOTEPATH=/home/ftpuser/ftp/files
KEYPATH=/etc/lamassu/keys/lamassu-log-server.key

timestamp() {
  date +"%Y%m%d-%H%M%S"
}

echo
echo "Bundling up recent server logs..."
echo

supervisorctl stop lamassu-server > /dev/null 2>&1

tar -cvjf $SERVER_LOG_ARCHIVE /isolate-*.log > /dev/null 2>&1

echo "Sending logs..."
echo

scp -i $KEYPATH -oStrictHostKeyChecking=no -P 22 $SERVER_LOG_ARCHIVE $USER@$HOST:$REMOTEPATH/ls-prof-log-$HOSTNAME-$(timestamp).tar.bz2 > /dev/null 2>&1

rm $SERVER_LOG_ARCHIVE

echo "Server logs sent. Restarting lamassu-server..."

curl -o /etc/supervisor/conf.d/lamassu-server.conf https://raw.githubusercontent.com/lamassu/lamassu-patches/master/logging/server/lamassu-server-orig.conf > /dev/null 2>&1

supervisorctl reread > /dev/null 2>&1
supervisorctl update lamassu-server > /dev/null 2>&1
supervisorctl start lamassu-server > /dev/null 2>&1

echo
echo "Done. Please let us know this is complete."
echo
