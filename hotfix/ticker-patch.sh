#!/usr/bin/env bash
set -e

echo
echo "Patching the tickers..."
echo
cd $(npm root -g)/lamassu-server/lib/plugins/ticker/
curl -#o bitpay/bitpay.js https://raw.githubusercontent.com/lamassu/lamassu-server/defiant-dingirma/lib/plugins/ticker/bitpay/bitpay.js
curl -#o bitstamp/bitstamp.js https://raw.githubusercontent.com/lamassu/lamassu-server/defiant-dingirma/lib/plugins/ticker/bitstamp/bitstamp.js
curl -#o kraken/kraken.js https://raw.githubusercontent.com/lamassu/lamassu-server/defiant-dingirma/lib/plugins/ticker/kraken/kraken.js
echo
supervisorctl restart lamassu-server lamassu-admin-server
echo
echo "Tickers patched."
echo
