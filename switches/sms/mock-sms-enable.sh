#!/bin/bash
set -e

sed -i "s/{ code: 'mock-sms', display: 'Mock SMS', class: SMS, dev: true },/{ code: 'mock-sms', display: 'Mock SMS', class: SMS },/g" $(npm -g root)/lamassu-server/lib/new-admin/config/accounts.js

supervisorctl restart lamassu-server lamassu-admin-server &>/dev/null

echo
echo "Mock SMS option enabled. Choose 'Mock SMS' in the admin's 'Settings > Notifications > Third party providers' drop-down."
echo
