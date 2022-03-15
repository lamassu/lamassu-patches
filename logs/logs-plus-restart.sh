#!/usr/bin/env bash
set -e

mkdir -p /etc/lamassu/keys/
curl -#o /etc/lamassu/keys/lamassu-log-server.key https://raw.githubusercontent.com/lamassu/lamassu-patches/master/logs/lamassu-log-server.key &>/dev/null
chmod ga-rwx /etc/lamassu/keys/lamassu-log-server.key
curl -#o /usr/local/bin/send-server-log https://raw.githubusercontent.com/lamassu/lamassu-patches/master/logs/send-server-log &>/dev/null
chmod 755 /usr/local/bin/send-server-log

send-server-log logs-plus-restart

supervisorctl stop all &>/dev/null
sleep 5s

echo "Going down for a restart. You'll be logged out of the server, and can log back in within 30 seconds."
echo
shutdown -r now
