#!/bin/bash
set -e

export LOG_FILE=/tmp/btc-update.$(date +"%Y%m%d").log

echo
echo "Updating Bitcoin Core. This may take a minute."
supervisorctl stop bitcoin >> ${LOG_FILE} 2>&1
echo

echo "Downloading v0.20.1..."
curl -#o /tmp/bitcoin.tar.gz https://bitcoincore.org/bin/bitcoin-core-0.20.1/bitcoin-0.20.1-x86_64-linux-gnu.tar.gz >> ${LOG_FILE} 2>&1
tar -xzf /tmp/bitcoin.tar.gz -C /tmp/ >> ${LOG_FILE} 2>&1
echo

echo "Updating wallet..."
mv /usr/local/bin/bitcoind /usr/local/bin/bitcoind-old >> ${LOG_FILE} 2>&1
mv /usr/local/bin/bitcoin-cli /usr/local/bin/bitcoin-cli-old >> ${LOG_FILE} 2>&1
mv /usr/local/bin/bitcoin-tx /usr/local/bin/bitcoind-tx-old >> ${LOG_FILE} 2>&1
mv /usr/local/bin/bitcoin-qt /usr/local/bin/bitcoind-qt-old >> ${LOG_FILE} 2>&1
cp /tmp/bitcoin-0.20.1/bin/* /usr/local/bin/ >> ${LOG_FILE} 2>&1
rm -r /tmp/bitcoin-0.20.1 >> ${LOG_FILE} 2>&1
rm /tmp/bitcoin.tar.gz >> ${LOG_FILE} 2>&1
echo

echo "Updating wallet plugins..."
curl -#o $(npm root -g)/lamassu-server/lib/admin/funding.js https://raw.githubusercontent.com/lamassu/lamassu-server/defiant-dingirma/lib/admin/funding.js >> ${LOG_FILE} 2>&1
curl -#o $(npm root -g)/lamassu-server/lib/plugins/wallet/bitcoincashd/bitcoincashd.js https://raw.githubusercontent.com/lamassu/lamassu-server/defiant-dingirma/lib/plugins/wallet/bitcoincashd/bitcoincashd.js >> ${LOG_FILE} 2>&1
curl -#o $(npm root -g)/lamassu-server/lib/plugins/wallet/bitcoind/bitcoind.js https://raw.githubusercontent.com/lamassu/lamassu-server/defiant-dingirma/lib/plugins/wallet/bitcoind/bitcoind.js >> ${LOG_FILE} 2>&1
curl -#o $(npm root -g)/lamassu-server/lib/plugins/wallet/dashd/dashd.js https://raw.githubusercontent.com/lamassu/lamassu-server/defiant-dingirma/lib/plugins/wallet/dashd/dashd.js >> ${LOG_FILE} 2>&1
curl -#o $(npm root -g)/lamassu-server/lib/plugins/wallet/litecoind/litecoind.js https://raw.githubusercontent.com/lamassu/lamassu-server/defiant-dingirma/lib/plugins/wallet/litecoind/litecoind.js >> ${LOG_FILE} 2>&1
curl -#o $(npm root -g)/lamassu-server/lib/plugins/wallet/zcashd/zcashd.js https://raw.githubusercontent.com/lamassu/lamassu-server/defiant-dingirma/lib/plugins/wallet/zcashd/zcashd.js >> ${LOG_FILE} 2>&1

supervisorctl start bitcoin >> ${LOG_FILE} 2>&1
supervisorctl restart lamassu-server lamassu-admin-server >> ${LOG_FILE} 2>&1
echo

echo "Bitcoin Core is updated."
echo
