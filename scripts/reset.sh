#!/usr/bin/env bash
set -euo pipefail
kubectl delete namespace k8s-ctf --ignore-not-found=true
rm -rf .generated
printf 'Deleted namespace k8s-ctf and local .generated files.\n'
