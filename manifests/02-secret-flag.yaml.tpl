apiVersion: v1
kind: Secret
metadata:
  name: vault-access
  namespace: k8s-ctf
  labels:
    challenge: "02"
type: Opaque
stringData:
  hint: Kubernetes Secrets are base64-encoded by default, not encrypted by magic.
data:
  flag: __FLAG_02_B64__
  decoy: SzhTQ1RGe2Zha2Vfc2VjcmV0X2ZsYWd9
