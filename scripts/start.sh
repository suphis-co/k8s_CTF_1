#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="k8s-ctf"
GENERATED_DIR=".generated"
GENERATED_MANIFESTS="$GENERATED_DIR/manifests"
PUBLIC_KEY="keys/facilitator_public.pem"
MODE="participant"

if [ "${1:-}" = "--facilitator" ]; then
  MODE="facilitator"
elif [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
  cat <<HELP
Usage: ./scripts/start.sh [--facilitator]

Default mode:
  - generates random flags
  - deploys the CTF
  - prints an encrypted submission blob
  - removes generated files containing real flags

Facilitator mode:
  - keeps .generated/facilitator-flags.json and generated manifests for debugging
HELP
  exit 0
fi

need_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

b64enc() {
  if base64 --help 2>&1 | grep -q -- '-w'; then
    base64 -w 0
  else
    base64 | tr -d '\n'
  fi
}

need_cmd kubectl
need_cmd openssl
need_cmd base64
need_cmd sed

if [ ! -f "$PUBLIC_KEY" ]; then
  echo "Public key not found: $PUBLIC_KEY" >&2
  echo "Ask the facilitator to add keys/facilitator_public.pem, or run ./scripts/setup-facilitator-keys.sh before publishing the repo." >&2
  exit 1
fi

rm -rf "$GENERATED_MANIFESTS"
mkdir -p "$GENERATED_MANIFESTS"

FLAG_01="K8SCTF{$(openssl rand -hex 8)}"
FLAG_02="K8SCTF{$(openssl rand -hex 8)}"
FLAG_03="K8SCTF{$(openssl rand -hex 8)}"
FLAG_04="K8SCTF{$(openssl rand -hex 8)}"
FLAG_05="K8SCTF{$(openssl rand -hex 8)}"
FLAG_06="K8SCTF{$(openssl rand -hex 8)}"
FLAG_07="K8SCTF{$(openssl rand -hex 8)}"
FLAG_02_B64="$(printf '%s' "$FLAG_02" | b64enc)"

cat > "$GENERATED_DIR/facilitator-flags.json" <<EOF_JSON
{"namespace":"$NAMESPACE","flag_01":"$FLAG_01","flag_02":"$FLAG_02","flag_03":"$FLAG_03","flag_04":"$FLAG_04","flag_05":"$FLAG_05","flag_06":"$FLAG_06","flag_07":"$FLAG_07"}
EOF_JSON

for template in manifests/*.yaml.tpl; do
  output="$GENERATED_MANIFESTS/$(basename "${template%.tpl}")"
  sed \
    -e "s|__FLAG_01__|$FLAG_01|g" \
    -e "s|__FLAG_02_B64__|$FLAG_02_B64|g" \
    -e "s|__FLAG_03__|$FLAG_03|g" \
    -e "s|__FLAG_04__|$FLAG_04|g" \
    -e "s|__FLAG_05__|$FLAG_05|g" \
    -e "s|__FLAG_06__|$FLAG_06|g" \
    -e "s|__FLAG_07__|$FLAG_07|g" \
    "$template" > "$output"
done

openssl pkeyutl \
  -encrypt \
  -pubin \
  -inkey "$PUBLIC_KEY" \
  -in "$GENERATED_DIR/facilitator-flags.json" \
  -out "$GENERATED_DIR/submission.bin" \
  -pkeyopt rsa_padding_mode:oaep

SUBMISSION_BLOB="$(base64 < "$GENERATED_DIR/submission.bin" | tr -d '\n')"

kubectl apply -f "$GENERATED_MANIFESTS/00-namespace.yaml"
kubectl apply -f "$GENERATED_MANIFESTS"

if [ "$MODE" != "facilitator" ]; then
  rm -f "$GENERATED_DIR/facilitator-flags.json"
  rm -f "$GENERATED_DIR/submission.bin"
  rm -rf "$GENERATED_MANIFESTS"
else
  rm -f "$GENERATED_DIR/submission.bin"
fi

cat <<EOF_OUT

Kubernetes CTF deployed.

Start with:
  kubectl get all -n $NAMESPACE

Send this encrypted submission blob to the facilitator:

$SUBMISSION_BLOB

EOF_OUT

if [ "$MODE" = "facilitator" ]; then
  cat <<EOF_FAC
Facilitator mode enabled. Kept:
  $GENERATED_DIR/facilitator-flags.json
  $GENERATED_MANIFESTS/
EOF_FAC
fi
