#!/usr/bin/env bash

echo
echo "Moving lamassu-server to new location..."
echo
supervisorctl stop lamassu-server lamassu-admin-server
mkdir -p /usr/lib/node_modules
mv /usr/lib/node_modules/lamassu-server /usr/lib/node_modules/lamassu-server-old
mv /usr/local/lib/node_modules/lamassu-server /usr/lib/node_modules/lamassu-server
rm /usr/local/bin/lamassu-server
rm /usr/local/bin/lamassu-admin-server
rm /usr/bin/lamassu-server
rm /usr/bin/lamassu-admin-server
ln -s /usr/lib/node_modules/lamassu-server/bin/lamassu-server /usr/bin/lamassu-server
ln -s /usr/lib/node_modules/lamassu-server/bin/lamassu-admin-server /usr/bin/lamassu-admin-server
curl -o /etc/supervisor/conf.d/lamassu-server.conf https://raw.githubusercontent.com/lamassu/lamassu-patches/master/correct/instances/server-restore/lamassu-server.conf
curl -o /etc/supervisor/conf.d/lamassu-admin-server.conf https://raw.githubusercontent.com/lamassu/lamassu-patches/master/correct/instances/server-restore/lamassu-admin-server.conf
supervisorctl reread
supervisorctl update lamassu-server lamassu-admin-server
echo
echo "Done."
echo
echo "Displaying status of supervisor processes..."
echo
supervisorctl status
echo
