#!/usr/bin/env bash

echo
echo "Making node_modules folder..."

mkdir -p /usr/lib/node_modules

echo
echo "Restoring npm..."

curl -sS https://ssubucket.ams3.digitaloceanspaces.com/server-rescue/npm.tar.xz | tar -xJ -C /usr/lib/node_modules/

echo
echo "Restoring corepack..."

curl -sS https://ssubucket.ams3.digitaloceanspaces.com/server-rescue/corepack.tar.xz | tar -xJ -C /usr/lib/node_modules/

echo
echo "Restoring lamassu-server..."

curl -sS https://ssubucket.ams3.digitaloceanspaces.com/server-rescue/lamassuserver.tar.xz | tar -xJ -C /usr/lib/node_modules/

echo
echo "Removing update lock..."

rmdir /var/lock/lamassu-update &>/dev/null

echo "Upgrading. Please wait up to 20 minutes..."

curl -sS https://raw.githubusercontent.com/lamassu/lamassu-patches/master/install/upgrade-ls-ff-migration | bash
