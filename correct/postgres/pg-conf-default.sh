#!/bin/bash
set -e

echo
echo "Resetting postgres timezone..."
echo
supervisorctl stop lamassu-server lamassu-admin-server &>/dev/null
curl -#o /etc/postgresql/9.5/main/postgresql.conf https://raw.githubusercontent.com/lamassu/lamassu-patches/master/correct/postgres/postgresql.conf &>/dev/null
/etc/init.d/postgresql restart &>/dev/null
supervisorctl start lamassu-server lamassu-admin-server &>/dev/null
echo "Done."
echo
