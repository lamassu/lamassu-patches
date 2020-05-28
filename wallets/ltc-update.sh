#!/bin/bash
set -e

export LOG_FILE=/tmp/ltc-update.$(date +"%Y%m%d").log

echo
echo "Updating Litecoin Core. This may take a minute."
supervisorctl stop litecoin >> ${LOG_FILE} 2>&1
echo

echo "Downloading v0.17.1..."
curl -#o /tmp/litecoin.tar.gz https://download.litecoin.org/litecoin-0.17.1/linux/litecoin-0.17.1-x86_64-linux-gnu.tar.gz >> ${LOG_FILE} 2>&1
tar -xzf /tmp/litecoin.tar.gz -C /tmp/ >> ${LOG_FILE} 2>&1
echo

echo "Updating wallet..."
mv /usr/local/bin/litecoind /usr/local/bin/litecoind-old >> ${LOG_FILE} 2>&1
mv /usr/local/bin/litecoin-cli /usr/local/bin/litecoin-cli-old >> ${LOG_FILE} 2>&1
mv /usr/local/bin/litecoin-tx /usr/local/bin/litecoin-tx-old >> ${LOG_FILE} 2>&1
mv /usr/local/bin/litecoin-qt /usr/local/bin/litecoin-qt-old >> ${LOG_FILE} 2>&1
cp /tmp/litecoin-0.17.1/bin/* /usr/local/bin/ >> ${LOG_FILE} 2>&1
rm -r /tmp/litecoin-0.17.1 >> ${LOG_FILE} 2>&1
rm /tmp/litecoin.tar.gz >> ${LOG_FILE} 2>&1
echo

echo "Updating wallet plugins..."
curl -#o $(npm root -g)/lamassu-server/lib/admin/funding.js https://raw.githubusercontent.com/lamassu/lamassu-server/defiant-dingirma/lib/admin/funding.js >> ${LOG_FILE} 2>&1
curl -#o $(npm root -g)/lamassu-server/lib/plugins/wallet/bitcoincashd/bitcoincashd.js https://raw.githubusercontent.com/lamassu/lamassu-server/defiant-dingirma/lib/plugins/wallet/bitcoincashd/bitcoincashd.js >> ${LOG_FILE} 2>&1
curl -#o $(npm root -g)/lamassu-server/lib/plugins/wallet/bitcoind/bitcoind.js https://raw.githubusercontent.com/lamassu/lamassu-server/defiant-dingirma/lib/plugins/wallet/bitcoind/bitcoind.js >> ${LOG_FILE} 2>&1
curl -#o $(npm root -g)/lamassu-server/lib/plugins/wallet/dashd/dashd.js https://raw.githubusercontent.com/lamassu/lamassu-server/defiant-dingirma/lib/plugins/wallet/dashd/dashd.js >> ${LOG_FILE} 2>&1
curl -#o $(npm root -g)/lamassu-server/lib/plugins/wallet/litecoind/litecoind.js https://raw.githubusercontent.com/lamassu/lamassu-server/defiant-dingirma/lib/plugins/wallet/litecoind/litecoind.js >> ${LOG_FILE} 2>&1
curl -#o $(npm root -g)/lamassu-server/lib/plugins/wallet/zcashd/zcashd.js https://raw.githubusercontent.com/lamassu/lamassu-server/defiant-dingirma/lib/plugins/wallet/zcashd/zcashd.js >> ${LOG_FILE} 2>&1

supervisorctl start litecoin >> ${LOG_FILE} 2>&1
supervisorctl restart lamassu-server lamassu-admin-server >> ${LOG_FILE} 2>&1
echo

echo "Litecoin Core is updated."
echo
