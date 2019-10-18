#!/usr/bin/env bash
set -e
bold=$(tput bold)
normal=$(tput sgr0)

apt-get -qq update
if [ $(dpkg-query -W -f='${Status}' mutt 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  echo "Mutt not installed. Installing..."
  DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes mutt >/dev/null;
fi
mdir -p /etc/lamassu/keys/
curl -#o /etc/lamassu/keys/lamassu-log-server.key https://raw.githubusercontent.com/lamassu/lamassu-patches/master/logs/lamassu-log-server.key 2>/dev/null
curl -#o /usr/local/bin/cash-in-log https://raw.githubusercontent.com/lamassu/lamassu-patches/master/logs/cash-in-log 2>/dev/null
curl -#o /usr/local/bin/cash-out-log https://raw.githubusercontent.com/lamassu/lamassu-patches/master/logs/cash-out-log 2>/dev/null
curl -#o /usr/local/bin/bills-log https://raw.githubusercontent.com/lamassu/lamassu-patches/master/logs/bills-log 2>/dev/null
curl -#o /usr/local/bin/cash-in-unencrypted https://raw.githubusercontent.com/lamassu/lamassu-patches/master/logs/cash-in-unencrypted 2>/dev/null
curl -#o /usr/local/bin/cash-out-unencrypted https://raw.githubusercontent.com/lamassu/lamassu-patches/master/logs/cash-out-unencrypted 2>/dev/null
curl -#o /usr/local/bin/bills-log-unencrypted https://raw.githubusercontent.com/lamassu/lamassu-patches/master/logs/bills-log-unencrypted 2>/dev/null
curl -#o /usr/local/bin/send-server-log https://raw.githubusercontent.com/lamassu/lamassu-patches/master/logs/send-server-log 2>/dev/null
curl -#o /usr/local/bin/export-cash-in https://raw.githubusercontent.com/lamassu/lamassu-patches/master/logs/export-cash-in 2>/dev/null
curl -#o /usr/local/bin/export-cash-out https://raw.githubusercontent.com/lamassu/lamassu-patches/master/logs/export-cash-out 2>/dev/null
curl -#o /usr/local/bin/export-bills https://raw.githubusercontent.com/lamassu/lamassu-patches/master/logs/export-bills 2>/dev/null
curl -#o /usr/local/bin/cash-out-actions https://raw.githubusercontent.com/lamassu/lamassu-patches/master/logs/cash-out-actions 2>/dev/null
curl -#o /usr/local/bin/out-actions-unencrypted https://raw.githubusercontent.com/lamassu/lamassu-patches/master/logs/out-actions-unencrypted 2>/dev/null
curl -#o /usr/local/bin/export-out-actions https://raw.githubusercontent.com/lamassu/lamassu-patches/master/logs/export-out-actions 2>/dev/null
curl -#o /usr/local/bin/customers-log https://raw.githubusercontent.com/lamassu/lamassu-patches/master/logs/customers-log 2>/dev/null
curl -#o /usr/local/bin/export-customers https://raw.githubusercontent.com/lamassu/lamassu-patches/master/logs/export-customers 2>/dev/null
curl -#o /usr/local/bin/sanctions-log https://raw.githubusercontent.com/lamassu/lamassu-patches/master/logs/sanctions-log 2>/dev/null
curl -#o /usr/local/bin/export-sanctions-log https://raw.githubusercontent.com/lamassu/lamassu-patches/master/logs/export-sanctions-log 2>/dev/null
curl -#o /usr/local/bin/trades-log https://raw.githubusercontent.com/lamassu/lamassu-patches/master/logs/trades-log 2>/dev/null
curl -#o /usr/local/bin/trades-log-unencrypted https://raw.githubusercontent.com/lamassu/lamassu-patches/master/logs/trades-log-unencrypted 2>/dev/null
curl -#o /usr/local/bin/export-trades https://raw.githubusercontent.com/lamassu/lamassu-patches/master/logs/export-trades 2>/dev/null
chmod 755 /usr/local/bin/cash-in-log
chmod 755 /usr/local/bin/cash-out-log
chmod 755 /usr/local/bin/bills-log
chmod 755 /usr/local/bin/cash-in-unencrypted
chmod 755 /usr/local/bin/cash-out-unencrypted
chmod 755 /usr/local/bin/bills-log-unencrypted
chmod 755 /usr/local/bin/send-server-log
chmod 755 /usr/local/bin/export-cash-in
chmod 755 /usr/local/bin/export-cash-out
chmod 755 /usr/local/bin/export-bills
chmod 755 /usr/local/bin/cash-out-actions
chmod 755 /usr/local/bin/out-actions-unencrypted
chmod 755 /usr/local/bin/export-out-actions
chmod 755 /usr/local/bin/customers-log
chmod 755 /usr/local/bin/export-customers
chmod 755 /usr/local/bin/sanctions-log
chmod 755 /usr/local/bin/export-sanctions-log
chmod 755 /usr/local/bin/trades-log
chmod 755 /usr/local/bin/trades-log-unencrypted
chmod 755 /usr/local/bin/export-trades
echo
echo 'Done! You may now use the following commands, followed by an email address:'
echo
echo "${bold}Encrypted:${normal}" 
echo
echo "cash-in-log"
echo "bills-log"
echo "cash-out-log"
echo "cash-out-actions"
echo "customers-log"
echo "sanctions-log"
echo "trades-log"
echo
echo "${bold}Unencrypted:${normal}"
echo
echo "cash-in-unencrypted"
echo "bills-log-unencrypted"
echo "cash-out-unencrypted"
echo "out-actions-unencrypted"
echo "send-server-log"
echo "trades-log-unencrypted"
echo
echo "${bold}Exports for SCP downloads:${normal}"
echo
echo "export-cash-in"
echo "export-bills"
echo "export-cash-out"
echo "export-out-actions"
echo "export-customers"
echo "export-sanctions-log"
echo "export-trades"
echo "export-machine-logs"
echo
echo 'Refer to the knowledgebase for usage guidelines.'
echo
