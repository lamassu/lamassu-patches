#!/usr/bin/env bash
set -e

echo
echo "Adding the lamassu-eth-recovery script..."
curl -#o $(npm root -g)/lamassu-server/bin/lamassu-eth-recovery https://raw.githubusercontent.com/lamassu/lamassu-patches/master/wallets/scripts/lamassu-eth-recovery &>/dev/null
ln -s $(npm root -g)/lamassu-server/bin/lamassu-eth-recovery /usr/local/bin/lamassu-eth-recovery &>/dev/null
chmod +x /usr/local/bin/lamassu-eth-recovery &>/dev/null
echo
echo "Done. To use, run:"
echo
echo "lamassu-eth-recovery 0x123"
echo
echo "where '0x123' is the ETH cash-out address whose private key you wish to display."
echo
