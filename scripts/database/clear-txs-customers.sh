#!/usr/bin/env bash
set -e

echo
echo "WARNING: This script will DELETE ALL transaction and ALL customer records from your database!"
echo
echo "Are you really sure you want to do this? (y/N)"
read input
if [[ $input == "Y" || $input == "y" ]]
then
  echo
  su - postgres -c "psql \"lamassu\" -Atc \"TRUNCATE cash_in_txs CASCADE\""
  su - postgres -c "psql \"lamassu\" -Atc \"TRUNCATE bills CASCADE\""
  su - postgres -c "psql \"lamassu\" -Atc \"TRUNCATE cash_out_txs CASCADE\""
  su - postgres -c "psql \"lamassu\" -Atc \"TRUNCATE cash_out_actions CASCADE\""
  su - postgres -c "psql \"lamassu\" -Atc \"TRUNCATE compliance_overrides CASCADE\""
  su - postgres -c "psql \"lamassu\" -Atc \"TRUNCATE customers CASCADE\""
  su - postgres -c "psql \"lamassu\" -Atc \"INSERT INTO customers (id) values ('47ac1184-8102-11e7-9079-8f13a7117867')\""
  echo
  echo "Done."
else
  echo
  echo "Cancelled."
fi
echo
