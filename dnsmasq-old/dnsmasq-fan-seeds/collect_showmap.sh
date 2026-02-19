#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./gen_all_showmaps.sh [fan-seeds-dir] [output-root-dir]
#
# Example:
#   ./gen_all_showmaps.sh ./fan-seeds ./maps

FAN_SEEDS_ROOT="${1:-./fan-seeds}"
OUTROOT="${2:-fan_showmaps}"

DNSMASQ="/home/ubuntu/experiments/dnsmasq/src/dnsmasq"
CONF="/etc/dnsmasq.conf"

if [[ ! -d "$FAN_SEEDS_ROOT" ]]; then
  echo "Error: fan-seeds root not found: $FAN_SEEDS_ROOT" >&2
  exit 2
fi

mkdir -p "$OUTROOT"

total_ok=0
total_fail=0

echo "[*] Searching for AFLNet runs inside $FAN_SEEDS_ROOT"

shopt -s nullglob
runs=( "$FAN_SEEDS_ROOT"/out-dnsmasq-aflnet_* )
shopt -u nullglob

if [[ ${#runs[@]} -eq 0 ]]; then
  echo "Error: no out-dnsmasq-aflnet_* folders found." >&2
  exit 2
fi

for run in "${runs[@]}"; do
  QUEUE_DIR="$run/queue"

  [[ -d "$QUEUE_DIR" ]] || continue

  run_name="$(basename "$run")"
  OUTDIR="$OUTROOT/$run_name"

  mkdir -p "$OUTDIR"

  echo
  echo "[*] Processing run: $run_name"

  shopt -s nullglob
  files=( "$QUEUE_DIR"/id* "$QUEUE_DIR"/*.raw )
  shopt -u nullglob

  for f in "${files[@]}"; do
    [[ -f "$f" ]] || continue

    name="$(basename "$f")"
    MAPFILE="$OUTDIR/$name.out"

    echo "    [+] $name"

    # start dnsmasq under afl-showmap
    afl-showmap -o "$MAPFILE" -c -q -m none -- \
      "$DNSMASQ" --no-daemon --conf-file="$CONF" &

    SM_PID=$!

    # allow bind
      # wait until dnsmasq actually listens on UDP 5353
      for i in {1..200}; do
        if netstat -anu 2>/dev/null | grep -q "127.0.0.1:5353"; then
          break
        fi
        sleep 0.02
      done

    # replay single DNS packet
    nc -u -w1 127.0.0.1 5353 < "$f" #>/dev/null 2>&1 || true
    total_ok=$((total_ok + 1))

    sleep 0.3

    # kill dnsmasq + afl-showmap
    kill "$SM_PID" 2>/dev/null || true
    wait "$SM_PID" 2>/dev/null || true
  done
done

echo
echo "Done."
echo "Maps root directory: $OUTROOT"
echo "Inputs processed ok: $total_ok, failed: $total_fail"






# afl-showmap -o test.out -c -q -m none -- ./experiments/dnsmasq/src/dnsmasq --no-daemon --conf-file=/etc/dnsmasq.conf &
# ./aflnet/aflnet-replay  ./fan-seeds/out-dnsmasq-aflnet_1/queue/* DNS 5353
