#!/usr/bin/env bash
set -e

curl -#o $(npm root -g)/lamassu-server/lib/admin/login.js https://raw.githubusercontent.com/lamassu/lamassu-patches/master/switches/admin/admin-otp-timeout.js &>/dev/null
supervisorctl restart lamassu-server lamassu-admin-server &>/dev/null
echo
lamassu-register link
echo
