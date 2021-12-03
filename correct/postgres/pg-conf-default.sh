#!/bin/bash
set -e

echo
echo "Resetting postgres configurations..."

supervisorctl stop lamassu-server lamassu-admin-server &>/dev/null

chmod 700 /var/lib/postgresql/12/main &>/dev/null

mv /var/lib/postgresql/12/main/postmaster.pid /var/lib/postgresql/12/main/postmaster.pid-old &>/dev/null

curl -#o /etc/postgresql/12/main/pg_hba.conf https://raw.githubusercontent.com/lamassu/lamassu-patches/master/correct/postgres/pg_hba.conf &>/dev/null

curl -#o /etc/postgresql/12/main/postgresql.conf https://raw.githubusercontent.com/lamassu/lamassu-patches/master/correct/postgres/postgresql.conf &>/dev/null

/etc/init.d/postgresql restart &>/dev/null

supervisorctl start lamassu-server lamassu-admin-server &>/dev/null

echo
echo "Done."
echo
