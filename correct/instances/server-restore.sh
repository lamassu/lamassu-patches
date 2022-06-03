#!/usr/bin/env bash

export LOG_FILE=/tmp/server-switch.$(date +"%Y%m%d").log

echo

supervisorctl stop lamassu-server lamassu-admin-server >> ${LOG_FILE} 2>&1

cd $(npm root -g)/ >> ${LOG_FILE} 2>&1
mv lamassu-server lamassu-server-bak >> ${LOG_FILE} 2>&1
cp -r lamassu-server-1654103126 lamassu-server >> ${LOG_FILE} 2>&1

perl -i -pe 's/command=.*/command=\/usr\/lib\/node_modules\/lamassu-server\/bin\/lamassu-server/g' /etc/supervisor/conf.d/lamassu-server.conf >> ${LOG_FILE} 2>&1
perl -i -pe 's/command=.*/command=\/usr\/lib\/node_modules\/lamassu-server\/bin\/lamassu-admin-server/g' /etc/supervisor/conf.d/lamassu-admin-server.conf >> ${LOG_FILE} 2>&1

supervisorctl update >> ${LOG_FILE} 2>&1
supervisorctl start lamassu-server lamassu-admin-server >> ${LOG_FILE} 2>&1

echo "Done!"
echo
