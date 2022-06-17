#!/usr/bin/env bash
set -e

echo
echo "WARNING: This script will DELETE ALL transaction records from your database!"
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
  echo
  echo "Done."
else
  echo
  echo "Cancelled."
fi
echo
