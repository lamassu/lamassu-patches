#!/bin/bash
set -e

echo
supervisorctl stop lamassu-machine &>/dev/null
sleep 2s
cd /opt/lamassu-machine
curl -#o lib/ccnet/ccnet-rs232.js https://raw.githubusercontent.com/lamassu/lamassu-machine/d366f081fdfcf4826b74f0597827f29197ba4ac8/lib/ccnet/ccnet-rs232.js &>/dev/null
curl -#o lib/ccnet/transmission-fsm.js https://raw.githubusercontent.com/lamassu/lamassu-machine/d366f081fdfcf4826b74f0597827f29197ba4ac8/lib/ccnet/transmission-fsm.js &>/dev/null
sleep 2s
supervisorctl start lamassu-machine &>/dev/null
echo "Done."
echo
