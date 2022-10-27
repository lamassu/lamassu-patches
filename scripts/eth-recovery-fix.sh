#!/usr/bin/env bash

echo
echo "Patching lamassu-eth-recovery..."

rm /usr/bin/lamassu-eth-recovery
curl -#o $(npm root -g)/lamassu-server/bin/lamassu-eth-recovery https://raw.githubusercontent.com/lamassu/lamassu-server/v8.0.3/bin/lamassu-eth-recovery

ln -s $(npm root -g)/lamassu-server/bin/lamassu-eth-recovery /usr/bin/lamassu-eth-recovery

echo
echo "Done. Please inform support that this script has been run."
echo
