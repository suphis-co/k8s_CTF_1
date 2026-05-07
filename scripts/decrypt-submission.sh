#!/usr/bin/env bash
set -euo pipefail

PRIVATE_KEY="${1:-keys/facilitator_private.pem}"
BLOB_FILE="${2:-}"
TMP_TXT="${TMPDIR:-/tmp}/k8s-ctf-submission.$$.txt"
TMP_BIN="${TMPDIR:-/tmp}/k8s-ctf-submission.$$.bin"

cleanup() {
  rm -f "$TMP_TXT" "$TMP_BIN"
}
trap cleanup EXIT

b64dec_file() {
  input_file="$1"
  output_file="$2"
  if base64 --decode "$input_file" > "$output_file" 2>/dev/null; then
    return 0
  fi
  if base64 -d "$input_file" > "$output_file" 2>/dev/null; then
    return 0
  fi
  if base64 -D -i "$input_file" -o "$output_file" 2>/dev/null; then
    return 0
  fi
  echo "Could not base64-decode the submission blob." >&2
  return 1
}

if [ ! -f "$PRIVATE_KEY" ]; then
  echo "Private key not found: $PRIVATE_KEY" >&2
  echo "Usage: ./scripts/decrypt-submission.sh <private-key> [blob-file]" >&2
  exit 1
fi

if [ -n "$BLOB_FILE" ]; then
  if [ ! -f "$BLOB_FILE" ]; then
    echo "Blob file not found: $BLOB_FILE" >&2
    exit 1
  fi
  tr -d '\n ' < "$BLOB_FILE" > "$TMP_TXT"
else
  tr -d '\n ' > "$TMP_TXT"
fi

b64dec_file "$TMP_TXT" "$TMP_BIN"

openssl pkeyutl \
  -decrypt \
  -inkey "$PRIVATE_KEY" \
  -in "$TMP_BIN" \
  -pkeyopt rsa_padding_mode:oaep

echo
