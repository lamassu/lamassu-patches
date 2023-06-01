#!/usr/bin/env bash
set -e

echo
cat /tmp/blacklist.csv | (echo "COPY blacklist FROM STDIN WITH (FORMAT csv, HEADER true);" && cat) | su - postgres -c "psql -U postgres -d \"lamassu"\"
echo
echo "Done!"
echo
