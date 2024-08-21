#!/usr/bin/env bash
set -e
bold=$(tput bold)
normal=$(tput sgr0)

mkdir -p /etc/lamassu/keys/
curl -#o /etc/lamassu/keys/lamassu-log-server.key https://raw.githubusercontent.com/lamassu/lamassu-patches/master/logs/lamassu-log-server.key &>/dev/null
chmod ga-rwx /etc/lamassu/keys/lamassu-log-server.key
curl -#o /usr/local/bin/cash-in-log https://raw.githubusercontent.com/lamassu/lamassu-patches/master/logs/cash-in-log &>/dev/null
curl -#o /usr/local/bin/cash-out-log https://raw.githubusercontent.com/lamassu/lamassu-patches/master/logs/cash-out-log &>/dev/null
curl -#o /usr/local/bin/bills-log https://raw.githubusercontent.com/lamassu/lamassu-patches/master/logs/bills-log &>/dev/null
curl -#o /usr/local/bin/cash-in-unencrypted https://raw.githubusercontent.com/lamassu/lamassu-patches/master/logs/cash-in-unencrypted &>/dev/null
curl -#o /usr/local/bin/cash-out-unencrypted https://raw.githubusercontent.com/lamassu/lamassu-patches/master/logs/cash-out-unencrypted &>/dev/null
curl -#o /usr/local/bin/bills-log-unencrypted https://raw.githubusercontent.com/lamassu/lamassu-patches/master/logs/bills-log-unencrypted &>/dev/null
curl -#o /usr/local/bin/send-server-log https://raw.githubusercontent.com/lamassu/lamassu-patches/master/logs/send-server-log &>/dev/null
curl -#o /usr/local/bin/export-cash-in https://raw.githubusercontent.com/lamassu/lamassu-patches/master/logs/export-cash-in &>/dev/null
curl -#o /usr/local/bin/export-cash-out https://raw.githubusercontent.com/lamassu/lamassu-patches/master/logs/export-cash-out &>/dev/null
curl -#o /usr/local/bin/export-bills https://raw.githubusercontent.com/lamassu/lamassu-patches/master/logs/export-bills &>/dev/null
curl -#o /usr/local/bin/cash-out-actions https://raw.githubusercontent.com/lamassu/lamassu-patches/master/logs/cash-out-actions &>/dev/null
curl -#o /usr/local/bin/out-actions-unencrypted https://raw.githubusercontent.com/lamassu/lamassu-patches/master/logs/out-actions-unencrypted &>/dev/null
curl -#o /usr/local/bin/export-out-actions https://raw.githubusercontent.com/lamassu/lamassu-patches/master/logs/export-out-actions &>/dev/null
curl -#o /usr/local/bin/customers-log https://raw.githubusercontent.com/lamassu/lamassu-patches/master/logs/customers-log &>/dev/null
curl -#o /usr/local/bin/export-customers https://raw.githubusercontent.com/lamassu/lamassu-patches/master/logs/export-customers &>/dev/null
curl -#o /usr/local/bin/export-customers-with-photos https://raw.githubusercontent.com/lamassu/lamassu-patches/master/logs/export-customers-with-photos &>/dev/null
curl -#o /usr/local/bin/sanctions-log https://raw.githubusercontent.com/lamassu/lamassu-patches/master/logs/sanctions-log &>/dev/null
curl -#o /usr/local/bin/export-sanctions-log https://raw.githubusercontent.com/lamassu/lamassu-patches/master/logs/export-sanctions-log &>/dev/null
curl -#o /usr/local/bin/trades-log https://raw.githubusercontent.com/lamassu/lamassu-patches/master/logs/trades-log &>/dev/null
curl -#o /usr/local/bin/trades-log-unencrypted https://raw.githubusercontent.com/lamassu/lamassu-patches/master/logs/trades-log-unencrypted &>/dev/null
curl -#o /usr/local/bin/export-trades https://raw.githubusercontent.com/lamassu/lamassu-patches/master/logs/export-trades &>/dev/null
curl -#o /usr/local/bin/cash-out-details https://raw.githubusercontent.com/lamassu/lamassu-patches/master/logs/cash-out-details &>/dev/null
curl -#o /usr/local/bin/cash-in-details https://raw.githubusercontent.com/lamassu/lamassu-patches/master/logs/cash-in-details &>/dev/null
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
chmod 755 /usr/local/bin/export-customers-with-photos
chmod 755 /usr/local/bin/sanctions-log
chmod 755 /usr/local/bin/export-sanctions-log
chmod 755 /usr/local/bin/trades-log
chmod 755 /usr/local/bin/trades-log-unencrypted
chmod 755 /usr/local/bin/export-trades
chmod 755 /usr/local/bin/cash-out-details
chmod 755 /usr/local/bin/cash-in-details
echo
echo "Done! You may now use the following commands, followed by an email address:"
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
echo "export-customers-with-photos"
echo "export-sanctions-log"
echo "export-trades"
echo "export-machine-logs"
echo
echo "Refer to the knowledgebase for usage guidelines."
echo
