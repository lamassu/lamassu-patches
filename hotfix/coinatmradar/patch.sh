#!/bin/bash
set -e

SERVER_RELEASE=$(node -p -e "require('$(npm root -g)/lamassu-server/package.json').version")
REQUIRED_RELEASE=7.4.1

echo
echo "Patching..."

if [ $(printf "%s\n" "$SERVER_RELEASE" "$REQUIRED_RELEASE" | sort -V -r | head -1) = "$SERVER_RELEASE" ] ; then
  if [ "$SERVER_RELEASE" = "$REQUIRED_RELEASE" ] ; then
    curl -#o $(npm root -g)/lamassu-server/lib/coinatmradar/coinatmradar.js https://raw.githubusercontent.com/lamassu/lamassu-server/defiant-dingirma/lib/coinatmradar/coinatmradar.js &>/dev/null
    supervisorctl restart lamassu-server &>/dev/null
  else
    curl -#o $(npm root -g)/lamassu-server/lib/coinatmradar/coinatmradar.js https://raw.githubusercontent.com/lamassu/lamassu-server/defiant-dingirma/lib/coinatmradar/coinatmradar.js &>/dev/null
    supervisorctl restart lamassu-server &>/dev/null
  fi
else
  curl -#o $(npm root -g)/lamassu-server/lib/coinatmradar/coinatmradar.js https://raw.githubusercontent.com/lamassu/lamassu-patches/master/hotfix/coinatmradar/cc-coinatmradar.js &>/dev/null
  supervisorctl restart lamassu-server &>/dev/null
fi

echo
echo "Patch complete."
echo
