#!/bin/bash
set -e

export LOG_FILE=/tmp/zec-update.$(date +"%Y%m%d").log

echo
echo "Updating your Zcash wallet. This may take a minute."
supervisorctl stop zcash >> ${LOG_FILE} 2>&1
add-apt-repository -y ppa:ubuntu-toolchain-r/test >> ${LOG_FILE} 2>&1
apt update >> ${LOG_FILE} 2>&1
apt install -y gcc-4.9 >> ${LOG_FILE} 2>&1
apt install -y --only-upgrade libstdc++6 >> ${LOG_FILE} 2>&1
echo

echo "Downloading Zcash v4.0.0..."
curl -#Lo /tmp/zcash.tar.gz https://download.z.cash/downloads/zcash-4.0.0-linux64-debian-stretch.tar.gz >> ${LOG_FILE} 2>&1
tar -xzf /tmp/zcash.tar.gz -C /tmp/ >> ${LOG_FILE} 2>&1
echo

echo "Updating wallet..."
mv /usr/local/bin/zcashd /usr/local/bin/zcashd-old >> ${LOG_FILE} 2>&1
mv /usr/local/bin/zcash-cli /usr/local/bin/zcash-cli-old >> ${LOG_FILE} 2>&1
mv /usr/local/bin/zcash-tx /usr/local/bin/zcash-tx-old >> ${LOG_FILE} 2>&1
mv /usr/local/bin/zcash-fetch-params /usr/local/bin/zcash-fetch-params-old >> ${LOG_FILE} 2>&1
cp /tmp/zcash-4.0.0/bin/* /usr/local/bin/ >> ${LOG_FILE} 2>&1
rm -r /tmp/zcash-4.0.0 >> ${LOG_FILE} 2>&1
rm /tmp/zcash.tar.gz >> ${LOG_FILE} 2>&1
echo

echo "Updating wallet plugins..."
curl -#o $(npm root -g)/lamassu-server/lib/admin/funding.js https://raw.githubusercontent.com/lamassu/lamassu-server/defiant-dingirma/lib/admin/funding.js >> ${LOG_FILE} 2>&1
curl -#o $(npm root -g)/lamassu-server/lib/plugins/wallet/bitcoincashd/bitcoincashd.js https://raw.githubusercontent.com/lamassu/lamassu-server/defiant-dingirma/lib/plugins/wallet/bitcoincashd/bitcoincashd.js >> ${LOG_FILE} 2>&1
curl -#o $(npm root -g)/lamassu-server/lib/plugins/wallet/bitcoind/bitcoind.js https://raw.githubusercontent.com/lamassu/lamassu-server/defiant-dingirma/lib/plugins/wallet/bitcoind/bitcoind.js >> ${LOG_FILE} 2>&1
curl -#o $(npm root -g)/lamassu-server/lib/plugins/wallet/dashd/dashd.js https://raw.githubusercontent.com/lamassu/lamassu-server/defiant-dingirma/lib/plugins/wallet/dashd/dashd.js >> ${LOG_FILE} 2>&1
curl -#o $(npm root -g)/lamassu-server/lib/plugins/wallet/litecoind/litecoind.js https://raw.githubusercontent.com/lamassu/lamassu-server/defiant-dingirma/lib/plugins/wallet/litecoind/litecoind.js >> ${LOG_FILE} 2>&1
curl -#o $(npm root -g)/lamassu-server/lib/plugins/wallet/zcashd/zcashd.js https://raw.githubusercontent.com/lamassu/lamassu-server/defiant-dingirma/lib/plugins/wallet/zcashd/zcashd.js >> ${LOG_FILE} 2>&1

supervisorctl start zcash >> ${LOG_FILE} 2>&1
supervisorctl restart lamassu-server lamassu-admin-server >> ${LOG_FILE} 2>&1
echo

echo "Zcash is updated."
echo
