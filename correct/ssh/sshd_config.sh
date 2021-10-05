#!/usr/bin/env bash
set -e

echo
echo "Downloading default SSH config...."
curl -#o /etc/ssh/sshd_config https://raw.githubusercontent.com/lamassu/lamassu-patches/master/correct/ssh/sshd_config
echo
echo "Restarting SSH..."
systemctl restart ssh
echo
echo "Done."
echo
