#!/usr/bin/env bash

echo
su - postgres -c "psql \"lamassu\" -At --expanded -c \"SELECT * FROM customers WHERE id = '81f9bf7b-63b0-45d5-be2f-3e03e4203b93'\""
echo
su - postgres -c "psql \"lamassu\" -At --expanded -c \"SELECT * FROM customers_custom_info_requests WHERE customer_id = '81f9bf7b-63b0-45d5-be2f-3e03e4203b93'\""
echo
