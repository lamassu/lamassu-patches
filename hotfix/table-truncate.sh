#!/usr/bin/env bash

echo
echo 'Cleaning up extraneous database entries (pings, event logs, and machine logs)...'
echo

supervisorctl stop lamassu-server lamassu-admin-server
su - postgres -c "pg_dump lamassu > /tmp/lamassu-database.bak"
echo 'Truncating machine_pings...'
su - postgres -c "psql \"lamassu\" -Atc \"DELETE FROM machine_pings WHERE created < NOW() - INTERVAL '1 hour'\""
echo 'Truncating machine_events...'
su - postgres -c "psql \"lamassu\" -Atc \"DELETE FROM machine_events WHERE created < NOW() - INTERVAL '1 hour'\""
echo 'Truncating server_events...'
su - postgres -c "psql \"lamassu\" -Atc \"DELETE FROM server_events WHERE created < NOW() - INTERVAL '1 hour'\""
echo 'Truncating machine logs...'
su - postgres -c "psql \"lamassu\" -Atc \"DELETE FROM logs WHERE timestamp < NOW() - INTERVAL '1 day'\""
supervisorctl start lamassu-server lamassu-admin-server
echo
echo 'Done.'
