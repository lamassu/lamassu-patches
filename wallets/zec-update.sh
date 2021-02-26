#!/bin/bash
set -e

export LOG_FILE=/tmp/zec-update.$(date +"%Y%m%d").log
SERVER_RELEASE=$(node -p -e "require('$(npm root -g)/lamassu-server/package.json').version")
REQUIRED_RELEASE=7.5.0

echo
echo "Updating your Zcash wallet. This may take a minute."
supervisorctl stop zcash >> ${LOG_FILE} 2>&1
echo

if [ $(printf "%s\n" "$SERVER_RELEASE" "$REQUIRED_RELEASE" | sort -V | head -1) = "$SERVER_RELEASE" ] ; then
  echo "Updating dependencies..."
  add-apt-repository -y ppa:ubuntu-toolchain-r/test >> ${LOG_FILE} 2>&1
  apt update >> ${LOG_FILE} 2>&1
  apt install -y gcc-4.9 >> ${LOG_FILE} 2>&1
  apt install -y --only-upgrade libstdc++6 >> ${LOG_FILE} 2>&1
  echo
fi

echo "Downloading Zcash v4.3.0..."
curl -#Lo /tmp/zcash.tar.gz https://z.cash/downloads/zcash-4.3.0-linux64-debian-stretch.tar.gz >> ${LOG_FILE} 2>&1
tar -xzf /tmp/zcash.tar.gz -C /tmp/ >> ${LOG_FILE} 2>&1
echo

echo "Updating wallet..."
mv /usr/local/bin/zcashd /usr/local/bin/zcashd-old >> ${LOG_FILE} 2>&1
mv /usr/local/bin/zcash-cli /usr/local/bin/zcash-cli-old >> ${LOG_FILE} 2>&1
mv /usr/local/bin/zcash-tx /usr/local/bin/zcash-tx-old >> ${LOG_FILE} 2>&1
mv /usr/local/bin/zcash-fetch-params /usr/local/bin/zcash-fetch-params-old >> ${LOG_FILE} 2>&1
cp /tmp/zcash-4.3.0/bin/* /usr/local/bin/ >> ${LOG_FILE} 2>&1
rm -r /tmp/zcash-4.3.0 >> ${LOG_FILE} 2>&1
rm /tmp/zcash.tar.gz >> ${LOG_FILE} 2>&1
echo

echo "Starting wallet..."
supervisorctl start zcash >> ${LOG_FILE} 2>&1
echo

echo "Zcash is updated."
echo
