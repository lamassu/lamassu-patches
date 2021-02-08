#!/usr/bin/env bash

echo
supervisorctl stop lamassu-server lamassu-admin-server
echo
su - postgres -c "psql \"lamassu\" -Atc \"ALTER TABLE cash_out_txs ADD COLUMN received_crypto_atoms numeric(30) null DEFAULT null\""
echo
supervisorctl start lamassu-server lamassu-admin-server
echo
