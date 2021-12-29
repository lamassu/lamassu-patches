#!/usr/bin/env bash
set -e

TABLE_LOG_DIR=/tmp/ftp-logs/migrations
TABLE_LOG_ARCHIVE=$TABLE_LOG_DIR/lamassu-migration-info_$HOSTNAME.tar.bz2
mkdir -p $TABLE_LOG_DIR

echo
echo "Compiling table descriptions and migration history, this may take a moment..."

# Main transaction tables
echo "$(su - postgres -c "psql \"lamassu\" -Atc \"\\d cash_in_txs\"")" >> $TABLE_LOG_DIR/table-columns-cash_in_txs.log
echo "$(su - postgres -c "psql \"lamassu\" -Atc \"\\d bills\"")" >> $TABLE_LOG_DIR/table-columns-bills.log
echo "$(su - postgres -c "psql \"lamassu\" -Atc \"\\d cash_out_txs\"")" >> $TABLE_LOG_DIR/table-columns-cash_out_txs.log
echo "$(su - postgres -c "psql \"lamassu\" -Atc \"\\d cash_out_actions\"")" >> $TABLE_LOG_DIR/table-columns-cash_out_actions.log

# Other recently migrated tables
echo "$(su - postgres -c "psql \"lamassu\" -Atc \"\\d customers\"")" >> $TABLE_LOG_DIR/table-columns-customers.log
echo "$(su - postgres -c "psql \"lamassu\" -Atc \"\\d blacklist\"")" >> $TABLE_LOG_DIR/table-columns-blacklist.log
echo "$(su - postgres -c "psql \"lamassu\" -Atc \"\\d machine_pings\"")" >> $TABLE_LOG_DIR/table-columns-machine_pings.log

# History of migration scripts run
echo "$(su - postgres -c "psql \"lamassu\" -Atc \"SELECT * FROM migrations;\"")" > $TABLE_LOG_DIR/migrations-history.log

# Recent server logs for good measure
echo "$(tail -250000 /var/log/supervisor/lamassu-server.err.log)" > $TABLE_LOG_DIR/lamassu-server.err.short.log
echo "$(tail -250000 /var/log/supervisor/lamassu-server.out.log)" > $TABLE_LOG_DIR/lamassu-server.out.short.log
echo "$(tail -250000 /var/log/supervisor/lamassu-admin-server.err.log)" > $TABLE_LOG_DIR/lamassu-admin-server.err.short.log

tar -cvjf $TABLE_LOG_ARCHIVE $TABLE_LOG_DIR/*.log &>/dev/null

timestamp() {
  date +"%Y%m%d-%H%M%S"
}

HOST=165.227.82.206
USER='ftpuser'
REMOTEPATH=/home/ftpuser/ftp/files
KEYPATH=/etc/lamassu/keys/lamassu-log-server.key
scp -i $KEYPATH -oStrictHostKeyChecking=no -P 22 $TABLE_LOG_ARCHIVE $USER@$HOST:$REMOTEPATH/migrations-$HOSTNAME-$(timestamp).tar.bz2 &>/dev/null

rm $TABLE_LOG_DIR/*

echo
echo "Done. Table descriptions and migration history sent to our support server."
echo

echo "Updating the Geth Ethereum wallet. This may take a minute."
supervisorctl stop ethereum &>/dev/null
echo

echo "Updating Ethereum configuration file..."
curl -#o /etc/supervisor/conf.d/ethereum.conf https://raw.githubusercontent.com/lamassu/lamassu-patches/master/wallets/conf/ethereum.conf &>/dev/null
echo

echo "Downloading Geth v1.10.14..."
curl -#o /tmp/ethereum.tar.gz https://gethstore.blob.core.windows.net/builds/geth-linux-amd64-1.10.14-11a3a350.tar.gz &>/dev/null
tar -xzf /tmp/ethereum.tar.gz -C /tmp/ &>/dev/null
echo

echo "Updating..."
cp /tmp/geth-linux-amd64-1.10.14-11a3a350/geth /usr/local/bin/geth
rm -r /tmp/geth-linux-amd64-1.10.14-11a3a350/
rm /tmp/ethereum.tar.gz
echo

echo "Starting wallet..."
supervisorctl reread &>/dev/null
supervisorctl update ethereum &>/dev/null
supervisorctl start ethereum &>/dev/null
echo

echo "Geth is updated."
echo

echo "Updating Bitcoin Core. This may take a minute."
supervisorctl stop bitcoin &>/dev/null
echo

echo "Downloading v22.0..."
curl -#o /tmp/bitcoin.tar.gz https://bitcoincore.org/bin/bitcoin-core-22.0/bitcoin-22.0-x86_64-linux-gnu.tar.gz &>/dev/null
tar -xzf /tmp/bitcoin.tar.gz -C /tmp/ &>/dev/null
echo

echo "Updating wallet..."
cp /tmp/bitcoin-22.0/bin/* /usr/local/bin/
rm -r /tmp/bitcoin-22.0
rm /tmp/bitcoin.tar.gz
echo

if grep -q "changetype=" /mnt/blockchains/bitcoin/bitcoin.conf
then
    echo "changetype already defined, skipping..."
else
    echo "Enabling bech32 change addresses in config file..."
    echo -e "\nchangetype=bech32" >> /mnt/blockchains/bitcoin/bitcoin.conf
fi
echo

echo "Starting wallet..."
supervisorctl start bitcoin &>/dev/null
echo

echo "Bitcoin Core is updated."
echo
