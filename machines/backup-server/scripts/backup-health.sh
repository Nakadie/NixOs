#!/usr/bin/env bash
# backup-health: verify the ZFS snapshot -> syncoid -> prune pipeline.
# Prints a one-line summary (goes to the journal). On any failure it posts to
# Discord and exits non-zero.
set -uo pipefail

webhook_file="${WEBHOOK_FILE:-/etc/backup-health/webhook}"
dataset="${DATASET:?DATASET not set}"
pool="${POOL:?POOL not set}"
timers="${TIMERS:-}"
peer="${PEER:-}"
peer_dataset="${PEER_DATASET:-$dataset}"
max_age_hourly="${MAX_AGE_HOURLY:-10800}"     # 3 h
max_age_daily="${MAX_AGE_DAILY:-172800}"      # 2 d
max_age_monthly="${MAX_AGE_MONTHLY:-3024000}" # 35 d
min_snapshots="${MIN_SNAPSHOTS:-1}"
min_free_gb="${MIN_FREE_GB:-50}"

problems=()
now=$(date +%s)

# Pool health and free space.
health=$(zpool list -H -o health "$pool" 2>/dev/null || true)
[ "$health" = ONLINE ] || problems+=("pool $pool is ${health:-missing}")
free_b=$(zpool list -Hp -o free "$pool" 2>/dev/null || echo 0)
free_gb=$(( free_b / 1024 / 1024 / 1024 ))
[ "$free_gb" -ge "$min_free_gb" ] || problems+=("pool $pool free ${free_gb}GiB < ${min_free_gb}GiB")

# Timers must still be active.
for t in $timers; do
  systemctl is-active --quiet "$t" || problems+=("$t is not active")
done

# Snapshot list, oldest first.
snaps=$(zfs list -t snapshot -Hp -o name,creation -s creation "$dataset" 2>/dev/null || true)
count=$(printf '%s\n' "$snaps" | grep -c . || true)
[ "$count" -ge "$min_snapshots" ] || problems+=("only $count snapshots on $dataset")

newest_age() {
  local ts
  ts=$(printf '%s\n' "$snaps" | awk -v t="_$1" '$1 ~ t {print $2}' | tail -1)
  [ -n "$ts" ] && echo $(( now - ts ))
}

for tier in hourly daily monthly; do
  case $tier in
    hourly)  max=$max_age_hourly ;;
    daily)   max=$max_age_daily ;;
    monthly) max=$max_age_monthly ;;
  esac
  age=$(newest_age "$tier")
  if [ -z "$age" ]; then
    problems+=("no $tier snapshot on $dataset")
  elif [ "$age" -gt "$max" ]; then
    problems+=("$tier snapshot age ${age}s > ${max}s")
  fi
done

# The target must hold the source's newest snapshot.
if [ -n "$peer" ]; then
  peer_newest=$(ssh -o BatchMode=yes -o ConnectTimeout=15 "$peer" \
    "zfs list -t snapshot -H -o name -s creation '$peer_dataset' | tail -1" 2>/dev/null || true)
  local_newest=$(printf '%s\n' "$snaps" | tail -1 | awk '{print $1}')
  if [ -z "$peer_newest" ]; then
    problems+=("cannot read newest snapshot from $peer")
  elif [ "${local_newest##*@}" != "${peer_newest##*@}" ]; then
    problems+=("newest snapshot mismatch: local=${local_newest##*@} peer=${peer_newest##*@}")
  fi
fi

if [ "${#problems[@]}" -eq 0 ]; then
  echo "backup-health OK: $dataset, $count snapshots, pool $pool $health, free ${free_gb}GiB"
  exit 0
fi

msg="backup-health FAIL on $(uname -n): $(printf '%s; ' "${problems[@]}")"
echo "$msg" >&2
if [ -r "$webhook_file" ]; then
  payload=$(jq -n --arg c "$msg" '{content:$c}')
  curl -sfS --max-time 20 -H 'Content-Type: application/json' --data "$payload" "$(cat "$webhook_file")" >/dev/null \
    || echo "warning: Discord post failed" >&2
fi
exit 1
