#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./gen_showmap_from_queue.sh /path/to/queue [outfile]

QUEUE_DIR="${1:-}"
OUTFILE="${2:-fan_showmap_1.out}"

DNSMASQ="/home/ubuntu/experiments/dnsmasq/src/dnsmasq"
CONF="/etc/dnsmasq.conf"

if [[ -z "$QUEUE_DIR" ]]; then
  echo "Usage: $0 /path/to/queue [outfile]" >&2
  exit 2
fi

if [[ ! -d "$QUEUE_DIR" ]]; then
  echo "Error: queue dir not found: $QUEUE_DIR" >&2
  exit 2
fi

: > "$OUTFILE"

echo "[*] Starting afl-showmap + dnsmasq..."

afl-showmap -o "$OUTFILE" -c -q -m none -- \
  "$DNSMASQ" --no-daemon --conf-file="$CONF" &

SM_PID=$!

# Give dnsmasq time to start and bind UDP socket
sleep 2

count_ok=0
count_fail=0

shopt -s nullglob
files=( "$QUEUE_DIR"/id* "$QUEUE_DIR"/*.raw )
shopt -u nullglob

for f in "${files[@]}"; do
  [[ -f "$f" ]] || continue

  echo "[*] Replaying $f"

  if nc -u 127.0.0.1 53 < "$f"; then
    count_ok=$((count_ok + 1))
  else
    count_fail=$((count_fail + 1))
    echo "Warn: replay failed for: $f" >&2
  fi

  # small delay so dnsmasq processes packet
  sleep 0.05
done

echo "[*] Stopping afl-showmap..."
kill "$SM_PID" 2>/dev/null || true
wait "$SM_PID" 2>/dev/null || true

echo "Done. Coverage map written to: $OUTFILE"
echo "Inputs sent ok: $count_ok, failed: $count_fail"




# afl-showmap -o test.out -c -q -m none -- ./experiments/dnsmasq/src/dnsmasq --no-daemon --conf-file=/etc/dnsmasq.conf &
# ./aflnet/aflnet-replay  ./fan-seeds/out-dnsmasq-aflnet_1/queue/* DNS 5353
