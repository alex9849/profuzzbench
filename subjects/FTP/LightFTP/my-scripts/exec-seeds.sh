#!/bin/bash

SEED_FILES=$1

set -euo pipefail

SEED_FILES="${1:-}"

if [[ -z "${SEED_FILES}" ]]; then
  echo "Usage: $0 /path/to/seed_file"
  echo "Env:"
#  echo "  GCOVR_FILTER   (required) regex for gcovr --filter (limits report to matching source file(s))"
  echo "  COV_OUT_DIR    (default: /cov_out) where html report is written (mount this from docker)"
  echo "  PORT           (default: 2200)"
  exit 2
fi

if [[ ! -d "${SEED_FILES}" ]]; then
  echo "Seed files not found: ${SEED_FILES}"
  exit 2
fi

: "${WORKDIR:?WORKDIR is not set (expected inside container)}"
#: "${GCOVR_FILTER:?GCOVR_FILTER is required, e.g. '.*LightFTP-gcov/Source/Release/fftp\\.c$' or '.*Source/Release/SomeFile\\.c$'}"

TARGET_DIR="LightFTP"
PORT="${PORT:-2200}"
COV_OUT_DIR="${COV_OUT_DIR:-/cov_out}"
# If COV_OUT_DIR is relative, make it relative to WORKDIR. If absolute, leave it.
if [[ ! "$COV_OUT_DIR" =~ ^/ ]]; then
  COV_OUT_DIR="${WORKDIR}/${COV_OUT_DIR}"
fi

mkdir -p "${COV_OUT_DIR}"

# Use gcov-instrumented build tree for execution + coverage.
cd "${WORKDIR}/${TARGET_DIR}-gcov/Source/Release"

# Clear previous gcov data (directory is Source/Release; sources are in parent "..")
gcovr -r .. -s -d > /dev/null 2>&1 || true

# Replay needs the server to be running.
# Run server in background, then replay.
pkill fftp > /dev/null 2>&1 || true

#timeout -k 0 -s SIGUSR1 5s
./fftp fftp.conf "${PORT}" > /dev/null 2>&1 &
SERVER_PID=$!

# Wait for server to start listening
for i in {1..20}; do
  if netstat -ltn 2>/dev/null | grep -q ":${PORT} "; then
    break
  fi
  sleep 0.1
done

rm -f $SEED_FILES/*_converted.raw
for f in $(echo $SEED_FILES/*); do
  echo $f
  echo "${f}_converted.raw"


  python3 /home/ubuntu/experiments/convert-to-replay.py $f "${f}_converted.raw"
  CONVERTED_SEED="${f}_converted.raw"
  aflnet-replay "${CONVERTED_SEED}" FTP "${PORT}" 1 > /dev/null 2>&1
  #sleep 1

done

kill -SIGUSR1 $SERVER_PID 2>/dev/null || true
wait $SERVER_PID || true


# Generate HTML coverage report for only the file(s) matching GCOVR_FILTER.
# --filter limits which source files appear in the report.
gcovr -r .. \
  --html --html-details \
  -o "${COV_OUT_DIR}index.html"

echo "Wrote coverage HTML to: ${COV_OUT_DIR}index.html"
