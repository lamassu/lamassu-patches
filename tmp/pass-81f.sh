#!/usr/bin/env bash

echo
su - postgres -c "psql \"lamassu\" -Atc \"UPDATE customers SET sanctions = 't' WHERE id = '81f9bf7b-63b0-45d5-be2f-3e03e4203b93'\""
echo
echo "Done."
echo
