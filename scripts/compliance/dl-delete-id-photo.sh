#!/usr/bin/env bash
set -e

bold=$(tput bold)
normal=$(tput sgr0)

echo
echo "Downloading the new command..."
curl -#o /usr/local/bin/delete-id-photo https://raw.githubusercontent.com/lamassu/lamassu-patches/master/scripts/compliance/delete-id-photo &>/dev/null
chmod 755 /usr/local/bin/delete-id-photo
echo
echo "Done! Now you may use the command: ${bold}delete-id-photo${normal}"
echo
