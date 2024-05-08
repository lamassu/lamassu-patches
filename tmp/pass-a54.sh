#!/usr/bin/env bash

echo
su - postgres -c "psql \"lamassu\" -Atc \"UPDATE customers SET sanctions = 't' WHERE id = 'a54b556f-6403-4821-ad7d-1bf39f1e86b3'\""
echo
echo "Done."
echo
