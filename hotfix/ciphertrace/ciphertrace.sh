#!/usr/bin/env bash
set -e

echo
echo "Updating CipherTrace libraries..."
echo

cd $(npm root -g)/lamassu-server/

curl -o lib/plugins/wallet-scoring/ciphertrace/ciphertrace.js https://raw.githubusercontent.com/lamassu/lamassu-server/release-8.0/lib/plugins/wallet-scoring/ciphertrace/ciphertrace.js &>/dev/null
curl -o lib/cash-out/cash-out-tx.js https://raw.githubusercontent.com/lamassu/lamassu-server/release-8.0/lib/cash-out/cash-out-tx.js &>/dev/null
curl -o lib/tx.js https://raw.githubusercontent.com/lamassu/lamassu-server/release-8.0/lib/tx.js &>/dev/null
curl -o lib/customers.js https://raw.githubusercontent.com/lamassu/lamassu-server/release-8.0/lib/customers.js &>/dev/null
curl -o test/stress/queries-performance-analyzer.js https://raw.githubusercontent.com/lamassu/lamassu-server/release-8.0/test/stress/queries-performance-analyzer.js &>/dev/null

sleep 2s
supervisorctl restart lamassu-server lamassu-admin-server &>/dev/null

echo "Updated."
echo
