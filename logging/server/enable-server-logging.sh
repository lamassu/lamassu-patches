#!/bin/bash

echo
echo "Setting lamassu-server process to log..."

supervisorctl stop lamassu-server > /dev/null 2>&1

curl -o /etc/supervisor/conf.d/lamassu-server.conf https://raw.githubusercontent.com/lamassu/lamassu-patches/master/logging/server/lamassu-server-prof.conf > /dev/null 2>&1

supervisorctl reread > /dev/null 2>&1
supervisorctl update lamassu-server > /dev/null 2>&1
supervisorctl start lamassu-server > /dev/null 2>&1

echo
echo "Done. lamassu-server is running. We'll circle back after a day or two with a script to upload logs."
echo
