#!/usr/bin/env bash

set -euo pipefail

umask 022

INSTALL_ROOT="${INSTALL_ROOT:-/}"
SKIP_SYSTEMD="${SKIP_SYSTEMD:-0}"
SUPPORT_KEY="${SUPPORT_KEY:-/etc/lamassu/keys/lamassu-log-server.key}"

if [[ $# -ne 0 ]]; then
  echo "Usage: $0" >&2
  exit 2
fi

if [[ "$INSTALL_ROOT" == "/" && "$(id -u)" -ne 0 ]]; then
  echo "ERROR: Run this installer as root." >&2
  exit 1
fi

root_path() {
  if [[ "$INSTALL_ROOT" == "/" ]]; then
    printf '%s' "$1"
  else
    printf '%s%s' "${INSTALL_ROOT%/}" "$1"
  fi
}

reporter_file="$(root_path /usr/local/bin/send-monthly-volume)"
service_file="$(root_path /etc/systemd/system/lamassu-monthly-volume.service)"
timer_file="$(root_path /etc/systemd/system/lamassu-monthly-volume.timer)"
state_dir="$(root_path /var/lib/lamassu-monthly-volume)"

tmp_dir="$(mktemp -d)"
cleanup() {
  rm -rf "$tmp_dir"
}
trap cleanup EXIT

reporter_payload="$tmp_dir/send-monthly-volume"
service_payload="$tmp_dir/lamassu-monthly-volume.service"
timer_payload="$tmp_dir/lamassu-monthly-volume.timer"

cat > "$reporter_payload" <<'REPORTER'
#!/usr/bin/env bash

set -euo pipefail

umask 077

DB_NAME="${DB_NAME:-lamassu}"
SUPPORT_HOST="${SUPPORT_HOST:-165.227.82.206}"
SUPPORT_USER="${SUPPORT_USER:-ftpuser}"
SUPPORT_PATH="${SUPPORT_PATH:-/home/ftpuser/ftp/files}"
SUPPORT_KEY="${SUPPORT_KEY:-/etc/lamassu/keys/lamassu-log-server.key}"
STATE_DIR="${STATE_DIR:-/var/lib/lamassu-monthly-volume}"
PSQL_BIN="${PSQL_BIN:-psql}"
SCP_BIN="${SCP_BIN:-scp}"
SUDO_BIN="${SUDO_BIN:-sudo}"
DATE_BIN="${DATE_BIN:-date}"
HOSTNAME_BIN="${HOSTNAME_BIN:-hostname}"
PSQL_AS_POSTGRES="${PSQL_AS_POSTGRES:-1}"
DRY_RUN="${DRY_RUN:-0}"
GENERATED_AT_OVERRIDE="${GENERATED_AT_OVERRIDE:-}"
OPERATOR_NAME_OVERRIDE="${OPERATOR_NAME_OVERRIDE:-}"

usage() {
  cat >&2 <<'USAGE'
Usage:
  send-monthly-volume
  send-monthly-volume YYYY-MM
  send-monthly-volume --automatic [YYYY-MM]
USAGE
}

automatic=0
if [[ "${1:-}" == "--automatic" ]]; then
  automatic=1
  shift
fi

if [[ $# -gt 1 ]]; then
  usage
  exit 2
fi

report_month="${1:-}"

hostname_value="$("$HOSTNAME_BIN" | tr -cd 'A-Za-z0-9._-')"
hostname_value="${hostname_value:-unknown-host}"
operator_name="${OPERATOR_NAME_OVERRIDE:-$hostname_value}"

if [[ -z "${operator_name:-}" || ${#operator_name} -gt 120 ||
      "$operator_name" =~ [[:cntrl:]] ]]; then
  echo "ERROR: Invalid operator name configuration." >&2
  exit 1
fi

psql_query() {
  local query="$1"
  shift

  if [[ "$PSQL_AS_POSTGRES" == "1" ]]; then
    (
      cd /tmp
      printf '%s\n' "$query" |
        "$SUDO_BIN" -u postgres \
          env "PGOPTIONS=-c default_transaction_read_only=on" \
          "$PSQL_BIN" -X -v ON_ERROR_STOP=1 -d "$DB_NAME" "$@"
    )
  else
    printf '%s\n' "$query" |
      PGOPTIONS="-c default_transaction_read_only=on" \
        "$PSQL_BIN" -X -v ON_ERROR_STOP=1 -d "$DB_NAME" "$@"
  fi
}

timezone_sql="
/* report:timezone */
SELECT COALESCE(data::jsonb->'config'->>'locale_timezone', 'UTC')
FROM user_config
WHERE type = 'config'
  AND valid = true
  AND schema_version = 2
ORDER BY id DESC
LIMIT 1;
"

timezone="$(psql_query "$timezone_sql" -At | head -n 1 | tr -d '\r')"
timezone="${timezone:-UTC}"

if [[ ! "$timezone" =~ ^[A-Za-z0-9._+-]+(/[A-Za-z0-9._+-]+)*$ ||
      ! -f "/usr/share/zoneinfo/$timezone" ]]; then
  echo "WARNING: Invalid configured timezone '$timezone'; using UTC." >&2
  timezone="UTC"
fi

if [[ -z "$report_month" ]]; then
  report_month="$(TZ="$timezone" "$DATE_BIN" -d "last month" +%Y-%m)"
fi

if [[ ! "$report_month" =~ ^[0-9]{4}-(0[1-9]|1[0-2])$ ]] ||
   [[ "$("$DATE_BIN" -d "$report_month-01" +%Y-%m 2>/dev/null || true)" != "$report_month" ]]; then
  echo "ERROR: Expected YYYY-MM for a real calendar month." >&2
  exit 2
fi

sent_marker="$STATE_DIR/sent-$report_month"

if [[ "$DRY_RUN" != "1" ]]; then
  mkdir -p "$STATE_DIR"
  chmod 700 "$STATE_DIR"
fi

if [[ "$DRY_RUN" != "1" && "$automatic" == "1" && -f "$sent_marker" ]]; then
  echo "Monthly volume $report_month was already sent."
  echo "RESULT: NO_CHANGE"
  exit 0
fi

generated_at="${GENERATED_AT_OVERRIDE:-$("$DATE_BIN" -u +%Y-%m-%dT%H:%M:%SZ)}"

work_dir="$(mktemp -d)"
cleanup() {
  rm -rf "$work_dir"
}
trap cleanup EXIT

report_dir="$work_dir/report"
mkdir -p "$report_dir"

bounds_cte="
bounds AS (
  SELECT
    ('$report_month-01'::timestamp AT TIME ZONE '$timezone') AS start_at,
    ((('$report_month-01'::date + INTERVAL '1 month')::timestamp)
      AT TIME ZONE '$timezone') AS end_at
),
included AS (
  SELECT
    'cashIn'::text AS direction,
    ci.device_id,
    COALESCE(d.name, 'Unknown') AS device_name,
    COALESCE(d.model, 'Unknown') AS model,
    COALESCE(d.version, 'Unknown') AS version,
    ci.fiat_code,
    ci.fiat
  FROM cash_in_txs ci
  CROSS JOIN bounds
  LEFT JOIN customers c ON c.id = ci.customer_id
  LEFT JOIN devices d ON d.device_id = ci.device_id
  WHERE ci.created >= bounds.start_at
    AND ci.created < bounds.end_at
    AND ci.send_confirmed = true
    AND ci.error IS NULL
    AND COALESCE(c.is_test_customer, false) = false

  UNION ALL

  SELECT
    'cashOut'::text AS direction,
    co.device_id,
    COALESCE(d.name, 'Unknown') AS device_name,
    COALESCE(d.model, 'Unknown') AS model,
    COALESCE(d.version, 'Unknown') AS version,
    co.fiat_code,
    co.fiat
  FROM cash_out_txs co
  CROSS JOIN bounds
  LEFT JOIN customers c ON c.id = co.customer_id
  LEFT JOIN devices d ON d.device_id = co.device_id
  WHERE co.created >= bounds.start_at
    AND co.created < bounds.end_at
    AND co.dispense = true
    AND co.error IS NULL
    AND COALESCE(c.is_test_customer, false) = false
)
"

counts_sql="
/* report:counts */
WITH $bounds_cte
SELECT
  (SELECT count(*) FROM devices),
  (SELECT count(DISTINCT device_id) FROM included);
"

counts="$(psql_query "$counts_sql" -AtF '|')"
IFS='|' read -r paired_device_count active_device_count <<< "$counts"
paired_device_count="${paired_device_count:-0}"
active_device_count="${active_device_count:-0}"

totals_sql="
/* report:currency-totals */
WITH $bounds_cte
SELECT
  fiat_code,
  count(*) FILTER (WHERE direction = 'cashIn') AS cash_in_count,
  COALESCE(sum(fiat) FILTER (WHERE direction = 'cashIn'), 0) AS cash_in_volume,
  count(*) FILTER (WHERE direction = 'cashOut') AS cash_out_count,
  COALESCE(sum(fiat) FILTER (WHERE direction = 'cashOut'), 0) AS cash_out_volume,
  count(*) AS total_count,
  COALESCE(sum(fiat), 0) AS total_volume
FROM included
GROUP BY fiat_code
ORDER BY fiat_code;
"

totals_file="$work_dir/currency-totals.txt"
psql_query "$totals_sql" -AtF '|' > "$totals_file"

device_csv_sql="
/* report:by-device */
COPY (
  WITH $bounds_cte
  SELECT
    device_name,
    device_id,
    model,
    version,
    fiat_code,
    count(*) FILTER (WHERE direction = 'cashIn') AS cash_in_count,
    COALESCE(sum(fiat) FILTER (WHERE direction = 'cashIn'), 0) AS cash_in_volume,
    count(*) FILTER (WHERE direction = 'cashOut') AS cash_out_count,
    COALESCE(sum(fiat) FILTER (WHERE direction = 'cashOut'), 0) AS cash_out_volume,
    count(*) AS total_count,
    COALESCE(sum(fiat), 0) AS total_volume
  FROM included
  GROUP BY device_name, device_id, model, version, fiat_code
  ORDER BY device_name, device_id, fiat_code
) TO STDOUT WITH (FORMAT CSV, HEADER true);
"

psql_query "$device_csv_sql" -At > "$report_dir/volume-by-device.csv"

manifest_sql="
/* report:manifest */
WITH $bounds_cte,
currency_totals AS (
  SELECT
    fiat_code,
    count(*) FILTER (WHERE direction = 'cashIn') AS cash_in_count,
    COALESCE(sum(fiat) FILTER (WHERE direction = 'cashIn'), 0) AS cash_in_volume,
    count(*) FILTER (WHERE direction = 'cashOut') AS cash_out_count,
    COALESCE(sum(fiat) FILTER (WHERE direction = 'cashOut'), 0) AS cash_out_volume,
    count(*) AS total_count,
    COALESCE(sum(fiat), 0) AS total_volume
  FROM included
  GROUP BY fiat_code
),
totals_json AS (
  SELECT COALESCE(
    jsonb_agg(
      jsonb_build_object(
        'fiatCode', fiat_code,
        'cashInCount', cash_in_count,
        'cashInVolume', cash_in_volume,
        'cashOutCount', cash_out_count,
        'cashOutVolume', cash_out_volume,
        'totalCount', total_count,
        'totalVolume', total_volume
      )
      ORDER BY fiat_code
    ),
    '[]'::jsonb
  ) AS value
  FROM currency_totals
)
SELECT jsonb_pretty(
  jsonb_build_object(
    'schemaVersion', 1,
    'operator', :'report_operator',
    'hostname', :'report_hostname',
    'reportingMonth', :'report_month',
    'timezone', :'report_timezone',
    'generatedAt', :'generated_at',
    'pairedDeviceCount', (SELECT count(*) FROM devices),
    'activeDeviceCount', (SELECT count(DISTINCT device_id) FROM included),
    'currencyTotals', (SELECT value FROM totals_json),
    'calculation', jsonb_build_object(
      'cashIn', 'send_confirmed = true AND error IS NULL',
      'cashOut', 'dispense = true AND error IS NULL',
      'testCustomersExcluded', true,
      'anonymousTransactionsIncluded', true,
      'fxConversion', false
    )
  )
);
"

psql_query "$manifest_sql" -At \
  -v "report_operator=$operator_name" \
  -v "report_hostname=$hostname_value" \
  -v "report_month=$report_month" \
  -v "report_timezone=$timezone" \
  -v "generated_at=$generated_at" \
  > "$report_dir/manifest.json"

summary_file="$report_dir/summary.txt"
{
  echo "Lamassu OSA v2 monthly volume report"
  echo "Operator: $operator_name"
  echo "Server: $hostname_value"
  echo "Reporting month: $report_month"
  echo "Timezone: $timezone"
  echo "Generated at: $generated_at"
  echo
  echo "Paired devices at generation: $paired_device_count"
  echo "Devices with successful volume: $active_device_count"
  echo
  echo "Native-currency totals:"
  if [[ -s "$totals_file" ]]; then
    while IFS='|' read -r fiat_code cash_in_count cash_in_volume \
      cash_out_count cash_out_volume total_count total_volume; do
      printf '%s | cash-in %s / %s | cash-out %s / %s | total %s / %s\n' \
        "$fiat_code" "$cash_in_count" "$cash_in_volume" \
        "$cash_out_count" "$cash_out_volume" "$total_count" "$total_volume"
    done < "$totals_file"
  else
    echo "No successful transaction volume."
  fi
  echo
  echo "Calculation:"
  echo "- Cash-in: send_confirmed = true AND error IS NULL"
  echo "- Cash-out: dispense = true AND error IS NULL"
  echo "- Test customers excluded; anonymous transactions included"
  echo "- Transaction month uses created timestamp in the timezone above"
  echo "- No FX conversion; unlike native currencies remain separate"
} > "$summary_file"

archive_name="${hostname_value}-${report_month}-monthly-volume.tar.gz"
archive_path="$work_dir/$archive_name"
tar -czf "$archive_path" -C "$report_dir" \
  summary.txt volume-by-device.csv manifest.json

if [[ "$DRY_RUN" == "1" ]]; then
  cat "$summary_file"
  echo
  echo "DRY RUN: upload and success marker skipped."
  echo "RESULT: DRY_RUN"
  exit 0
fi

if [[ ! -r "$SUPPORT_KEY" ]]; then
  echo "ERROR: Support upload key not readable: $SUPPORT_KEY" >&2
  exit 1
fi

remote_destination="${SUPPORT_USER}@${SUPPORT_HOST}:${SUPPORT_PATH}/${archive_name}"
"$SCP_BIN" \
  -i "$SUPPORT_KEY" \
  -o BatchMode=yes \
  -o StrictHostKeyChecking=accept-new \
  -P 22 \
  "$archive_path" \
  "$remote_destination"

if [[ "$automatic" == "1" ]]; then
  marker_tmp="$STATE_DIR/.sent-$report_month.$$"
  printf 'uploaded=%s\narchive=%s\n' "$generated_at" "$archive_name" > "$marker_tmp"
  chmod 600 "$marker_tmp"
  mv "$marker_tmp" "$sent_marker"
fi

echo "Monthly volume report sent: $archive_name"
echo "RESULT: SENT"
REPORTER

cat > "$service_payload" <<'SERVICE'
[Unit]
Description=Send Lamassu monthly OSA volume report
After=postgresql.service network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/send-monthly-volume --automatic
SERVICE

cat > "$timer_payload" <<'TIMER'
[Unit]
Description=Retry Lamassu monthly OSA volume reporting daily

[Timer]
OnCalendar=*-*-* 14:15:00 UTC
RandomizedDelaySec=30m
Persistent=true

[Install]
WantedBy=timers.target
TIMER

chmod 755 "$reporter_payload"
chmod 644 "$service_payload" "$timer_payload"

changed=0
backup_stamp="$(date -u +%Y%m%d-%H%M%S)"

install_payload() {
  local source_file="$1"
  local destination="$2"
  local mode="$3"

  mkdir -p "$(dirname "$destination")"

  if [[ -f "$destination" ]] && cmp -s "$source_file" "$destination"; then
    chmod "$mode" "$destination"
    return
  fi

  if [[ -e "$destination" ]]; then
    cp -a "$destination" "${destination}.backup-${backup_stamp}"
  fi

  install -m "$mode" "$source_file" "$destination"
  changed=1
}

install_payload "$reporter_payload" "$reporter_file" 755
install_payload "$service_payload" "$service_file" 644
install_payload "$timer_payload" "$timer_file" 644
mkdir -p "$state_dir"
chmod 700 "$state_dir"

bash -n "$reporter_file"

if [[ "$INSTALL_ROOT" == "/" ]]; then
  command -v psql >/dev/null 2>&1 ||
    { echo "ERROR: psql is required." >&2; exit 1; }
  command -v scp >/dev/null 2>&1 ||
    { echo "ERROR: scp is required." >&2; exit 1; }
  command -v tar >/dev/null 2>&1 ||
    { echo "ERROR: tar is required." >&2; exit 1; }
  [[ -r "$SUPPORT_KEY" ]] ||
    { echo "ERROR: Support key not readable: $SUPPORT_KEY" >&2; exit 1; }
fi

run_quiet_or_fail() {
  local description="$1"
  shift
  local output

  if ! output="$("$@" 2>&1)"; then
    echo "ERROR: $description failed." >&2
    [[ -n "$output" ]] && printf '%s\n' "$output" >&2
    return 1
  fi
}

if [[ "$SKIP_SYSTEMD" != "1" ]]; then
  command -v systemctl >/dev/null 2>&1 ||
    { echo "ERROR: systemctl is required." >&2; exit 1; }
  command -v systemd-analyze >/dev/null 2>&1 ||
    { echo "ERROR: systemd-analyze is required." >&2; exit 1; }

  run_quiet_or_fail "systemd unit verification" \
    systemd-analyze verify "$service_file" "$timer_file"
  run_quiet_or_fail "systemd daemon reload" systemctl daemon-reload
  run_quiet_or_fail "timer activation" \
    systemctl enable --now lamassu-monthly-volume.timer
fi

echo "Done"
