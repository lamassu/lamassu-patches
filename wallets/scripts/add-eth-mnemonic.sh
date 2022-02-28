#!/usr/bin/env bash
set -e

echo
echo "Adding the lamassu-eth-mnemonic script..."
curl -#o $(npm root -g)/lamassu-server/bin/lamassu-eth-mnemonic https://raw.githubusercontent.com/lamassu/lamassu-patches/master/wallets/scripts/lamassu-eth-mnemonic &>/dev/null
ln -s $(npm root -g)/lamassu-server/bin/lamassu-eth-mnemonic /usr/local/bin/lamassu-eth-mnemonic &>/dev/null
chmod +x /usr/local/bin/lamassu-eth-mnemonic &>/dev/null
echo
echo "Done. To use, run:"
echo
echo "lamassu-eth-mnemonic"
echo
