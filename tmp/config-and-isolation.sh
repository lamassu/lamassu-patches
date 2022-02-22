#!/usr/bin/env bash

NAME=$1
if [ ! $# -eq 1 ]; then
  echo "send-config <name>"
  exit 1
elif [[ ! $NAME =~ . ]]; then
  echo "Please enter your name"
  echo
  echo "send-config <name>"
  exit 1
fi

echo
echo "Compiling config records..."
echo

CONFIG_RECORD=/tmp/lamassu-config_$HOSTNAME.csv
CONFIG_ARCHIVE=/tmp/lamassu-config_$HOSTNAME.csv.tar.bz2

# clean up existing logs
rm $CONFIG_RECORD &>/dev/null
rm $CONFIG_ARCHIVE &>/dev/null
rm /tmp/tx-isolation.log &>/dev/null

# export config info
su - postgres -c "psql \"lamassu\" -Atc \"COPY (SELECT * FROM user_config WHERE type = 'config') to '$CONFIG_RECORD' WITH CSV HEADER\"" &>/dev/null
echo "$(su - postgres -c "psql \"lamassu\" -Atc \"SHOW default_transaction_isolation\"")" >> /tmp/tx-isolation.log
echo "$(su - postgres -c "psql \"lamassu\" -Atc \"SHOW transaction_isolation\"")" >> /tmp/tx-isolation.log

# compress it
tar -cvjf $CONFIG_ARCHIVE $CONFIG_RECORD /tmp/tx-isolation.log &>/dev/null

timestamp() {
  date +"%Y%m%d-%H%M%S"
}

echo "Uploading config logs..."
echo

HOST=165.227.82.206
USER='ftpuser'
REMOTEPATH=/home/ftpuser/ftp/files
KEYPATH=/etc/lamassu/keys/lamassu-log-server.key
scp -i $KEYPATH -oStrictHostKeyChecking=no -P 22 $CONFIG_ARCHIVE $USER@$HOST:$REMOTEPATH/$NAME-$HOSTNAME-$(timestamp).csv.tar.bz2 &>/dev/null

# clean up logs
rm $CONFIG_RECORD &>/dev/null
rm $CONFIG_ARCHIVE &>/dev/null
rm /tmp/tx-isolation.log &>/dev/null

echo "Config logs sent to our support server. Please let us know."
echo
