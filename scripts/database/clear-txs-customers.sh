#!/usr/bin/env bash
set -e

echo
echo "WARNING: This script will DELETE all transaction and customer records from your database!"
echo
echo "Are you really sure you want to do this? (y/N)"
read input
if [[ $input == "Y" || $input == "y" ]]
then
  echo
  su - postgres -c "psql \"lamassu\" -Atc \"DELETE FROM cash_in_txs\""
  su - postgres -c "psql \"lamassu\" -Atc \"DELETE FROM bills\""
  su - postgres -c "psql \"lamassu\" -Atc \"DELETE FROM cash_out_txs\""
  su - postgres -c "psql \"lamassu\" -Atc \"DELETE FROM cash_out_actions\""
  su - postgres -c "psql \"lamassu\" -Atc \"DELETE FROM compliance_overrides\""
  su - postgres -c "psql \"lamassu\" -Atc \"DELETE FROM customers\""
  su - postgres -c "psql \"lamassu\" -Atc \"INSERT INTO customers (id) values ('47ac1184-8102-11e7-9079-8f13a7117867')\""
  echo
  echo "Done."
else
  echo
  echo "Cancelled."
fi
echo
