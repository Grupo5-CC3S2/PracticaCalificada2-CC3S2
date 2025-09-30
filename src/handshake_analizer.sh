#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="${ROOT_DIR}/out"
mkdir -p "$OUT_DIR"

# Config variables
LOCAL_HOST="${HOST:-localhost}"
LOCAL_PORT="${PORT:-8080}"
TARGET_HOST="${TARGET_HOST:-example.org}"
TARGET_PORT="${TARGET_PORT:-443}"

echo -n "" > $OUT_DIR/ss_trace.txt

(
    i=0
    while true; do
        i=$((i + 1))
        echo ">>> Salida $i" >> "$OUT_DIR/ss_trace.txt"
        ss -tanp | grep -E "(nc|openssl|curl)" >> "$OUT_DIR/ss_trace.txt"
        sleep 0.1
    done
) &
SS_PID=$!

echo "Capturando traza HTTP local (servicio local - GET /salud)..." >&2
curl -v "http://${LOCAL_HOST}:${LOCAL_PORT}/salud" -s -o /dev/null 2> "$OUT_DIR/http_local_post_traza.txt" || true

echo "Capturando traza HTTPS (servicio público ${TARGET_HOST} - GET)..." >&2
curl -v "https://${TARGET_HOST}" -s -o /dev/null 2> "$OUT_DIR/https_${TARGET_HOST}_traza.txt" || true

echo "Ejecutando openssl s_client para inspeccionar certificado..." >&2
# redirige stdin para que s_client no espere
openssl s_client -connect "${TARGET_HOST}:${TARGET_PORT}" -msg -showcerts < /dev/null > "$OUT_DIR/openssl_${TARGET_HOST}.txt" 2>&1 || true

kill $SS_PID

echo "Archivos generados en $OUT_DIR:" >&2
ls -1 "$OUT_DIR"
