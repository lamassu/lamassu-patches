#!/usr/bin/env bash
set -e

export LOG_FILE=/tmp/update.$(date +"%Y%m%d").log

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
UBUNTU_VERSION=$(lsb_release -rs)

rm -f ${LOG_FILE}

decho () {
  echo `date +"%H:%M:%S"` $1
  echo `date +"%H:%M:%S"` $1 >> ${LOG_FILE}
}

cat <<'FIG'
 _
| | __ _ _ __ ___   __ _ ___ ___ _   _       ___  ___ _ ____   _____ _ __
| |/ _` | '_ ` _ \ / _` / __/ __| | | |_____/ __|/ _ \ '__\ \ / / _ \ '__|
| | (_| | | | | | | (_| \__ \__ \ |_| |_____\__ \  __/ |   \ V /  __/ |
|_|\__,_|_| |_| |_|\__,_|___/___/\__,_|     |___/\___|_|    \_/ \___|_|
FIG

echo -e "\nStarting \033[1mlamassu-server\033[0m update. This will take a few minutes...\n"

if [ "$(whoami)" != "root" ]; then
  echo -e "This script has to be run as \033[1mroot\033[0m user"
  exit 3
fi

# Use a lock file so failed scripts cannot be imediately retried
# If not the backup created on this script would be replaced
# if ! mkdir /var/lock/lamassu-update; then
#   echo "Script is locked because of a failure." >&2
#   exit 1
# fi

if [[ "$UBUNTU_VERSION" == "20.04" ]]; then
  echo -e "\033[1mDetected Ubuntu version: 20.04. Your operating system is up to date.\033[0m"
  echo
  echo -e "\033[1mUpdating lamassu-server to Electric Enlil v7.5.6...\033[0m"
  echo

  export NPM_BIN=$(npm -g bin)

  decho "stopping lamassu-server"
  set +e
  supervisorctl stop lamassu-server >> ${LOG_FILE} 2>&1
  supervisorctl stop lamassu-admin-server >> ${LOG_FILE} 2>&1
  set -e

  decho "unlinking ${NPM_BIN}/lamassu* old executables"
  find ${NPM_BIN} -type l \( -name "lamassu-*" -or -name "hkdf" \) -exec rm -fv {} \; >> ${LOG_FILE} 2>&1

  if [ -d "/usr/lib/node_modules/lamassu-server" ]; then
      BKP_NAME=lamassu-server-$(date +%s)
      decho "renaming old lamassu-server instance to ${BKP_NAME}"
      mv -v "/usr/lib/node_modules/lamassu-server" "/usr/lib/node_modules/${BKP_NAME}" >> ${LOG_FILE} 2>&1
  fi

  decho "updating lamassu-server to Electric Enlil v7.5.6..."
  npm -g install lamassu/lamassu-server#v7.5.6 --unsafe-perm >> ${LOG_FILE} 2>&1

  decho "rebuilding npm deps"
  cd $(npm root -g)/lamassu-server/ >> ${LOG_FILE} 2>&1
  npm rebuild >> ${LOG_FILE} 2>&1

  {
  decho "running migration"
    lamassu-migrate >> ${LOG_FILE} 2>&1
  } || { echo "Failure running migrations" ; exit 1 ; }

  lamassu-migrate-config >> ${LOG_FILE} 2>&1

  decho "update to mnemonic"
  lamassu-update-to-mnemonic --prod >> ${LOG_FILE} 2>&1

  decho "update ofac sources"
  lamassu-ofac-update-sources >> ${LOG_FILE} 2>&1

  decho "updating supervisor conf"
  perl -i -pe 's/command=.*/command=$ENV{NPM_BIN}\/lamassu-server/g' /etc/supervisor/conf.d/lamassu-server.conf >> ${LOG_FILE} 2>&1
  perl -i -pe 's/command=.*/command=$ENV{NPM_BIN}\/lamassu-admin-server/g' /etc/supervisor/conf.d/lamassu-admin-server.conf >> ${LOG_FILE} 2>&1
  cat <<EOF >> /etc/supervisor/supervisord.conf
[inet_http_server]
port = 127.0.0.1:9001
EOF

  decho "updating lamassu-server"
  set +e
  supervisorctl reread >> ${LOG_FILE} 2>&1
  supervisorctl update lamassu-server >> ${LOG_FILE} 2>&1
  supervisorctl update lamassu-admin-server >> ${LOG_FILE} 2>&1
  supervisorctl start lamassu-server >> ${LOG_FILE} 2>&1
  supervisorctl start lamassu-admin-server >> ${LOG_FILE} 2>&1
  set -e

  decho "updating backups conf"
  BACKUP_CMD=${NPM_BIN}/lamassu-backup-pg
  BACKUP_CRON="@daily $BACKUP_CMD > /dev/null"
  ( (crontab -l 2>/dev/null || echo -n "") | grep -v '@daily.*lamassu-backup-pg'; echo $BACKUP_CRON ) | crontab - >> $LOG_FILE 2>&1
  $BACKUP_CMD >> $LOG_FILE 2>&1

  decho "updating motd scripts"
  set +e
  chmod -x /etc/update-motd.d/*-release-upgrade 2>/dev/null
  chmod -x /etc/update-motd.d/*-updates-available 2>/dev/null
  chmod -x /etc/update-motd.d/*-reboot-required 2>/dev/null
  chmod -x /etc/update-motd.d/*-help-text 2>/dev/null
  chmod -x /etc/update-motd.d/*-cloudguest 2>/dev/null
  chmod -x /etc/update-motd.d/*-motd-news 2>/dev/null
  set -e

  echo
  echo -e "\033[1mLamassu server update complete!\033[0m"
  echo
else
  echo
  echo -e "\033[0;31mOld Ubuntu version detected ($UBUNTU_VERSION). Make sure that Ubuntu is on either version 16.04 or 18.04 and update it.\033[0m"
  echo "To update this machine's operating system, please run the following command in this machine's terminal:"
  echo
  echo -e "\033[1mcurl -sS https://raw.githubusercontent.com/lamassu/lamassu-install/electric-enlil/upgrade-os | bash\033[0m"
  echo
fi

# reset terminal to link new executables
hash -r

rm -r /var/lock/lamassu-update
