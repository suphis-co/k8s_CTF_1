#!/usr/bin/env bash
set -euo pipefail

mkdir -p keys
PRIVATE_KEY="keys/facilitator_private.pem"
PUBLIC_KEY="keys/facilitator_public.pem"

if [ -f "$PRIVATE_KEY" ]; then
  echo "Private key already exists: $PRIVATE_KEY" >&2
  echo "Remove it first if you really want to rotate keys." >&2
  exit 1
fi

openssl genpkey \
  -algorithm RSA \
  -out "$PRIVATE_KEY" \
  -pkeyopt rsa_keygen_bits:4096

chmod 600 "$PRIVATE_KEY"

openssl rsa \
  -pubout \
  -in "$PRIVATE_KEY" \
  -out "$PUBLIC_KEY"

cat <<EOF_OUT
Created facilitator keys:
  $PRIVATE_KEY  keep this private; never commit it
  $PUBLIC_KEY   commit this public key before sharing the repo
EOF_OUT
