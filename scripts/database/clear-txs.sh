#!/usr/bin/env bash
set -e

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
