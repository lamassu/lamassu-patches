#!/usr/bin/env bash

echo
echo "Moving lamassu-server to new location..."
echo
supervisorctl stop lamassu-server lamassu-admin-server
rm /usr/bin/lamassu-server
rm /usr/bin/lamassu-admin-server
ln -s /usr/lib/node_modules/lamassu-server/bin/lamassu-server /usr/bin/lamassu-server
ln -s /usr/lib/node_modules/lamassu-server/bin/lamassu-admin-server /usr/bin/lamassu-admin-server
supervisorctl start lamassu-server lamassu-admin-server
echo
echo "Done."
echo
