#!/usr/bin/env bash

TABLE_NAME=(aggregated_machine_pings bills blacklist cash_in_actions cash_in_actions_id_seq cash_in_refills cash_in_txs cash_out_actions cash_out_actions_id_seq cash_out_refills cash_out_txs compliance_overrides coupons customers devices hd_indices_seq logs machine_events machine_pings migrations migrations_id_seq notifications one_time_passes pairing_tokens pairing_tokens_id_seq sanctions_logs server_events server_events_id_seq server_logs trades trades_id_seq user_config user_config_id_seq user_tokens)

echo
for i in "${TABLE_NAME[@]}"
do
    TABLE_NAME=$(echo "$i")
    TABLE_COUNT=$(su - postgres -c "psql \"lamassu\" -Atc \"SELECT COUNT(*) FROM $i\"")
    OUTPUT="$TABLE_NAME | $TABLE_COUNT"
    echo $OUTPUT
done
echo
