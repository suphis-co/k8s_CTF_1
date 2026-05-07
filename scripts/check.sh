#!/usr/bin/env bash
set -euo pipefail
kubectl get namespace k8s-ctf >/dev/null
kubectl get configmap mission-briefing -n k8s-ctf >/dev/null
kubectl get secret vault-access -n k8s-ctf >/dev/null
kubectl get job forensic-printer -n k8s-ctf >/dev/null
kubectl get deployment ctf-web -n k8s-ctf >/dev/null
kubectl get pod archive-reader -n k8s-ctf >/dev/null
kubectl get deployment unstable-app -n k8s-ctf >/dev/null
kubectl get pod intern-terminal -n k8s-ctf >/dev/null
printf 'Core CTF resources exist.\n'
