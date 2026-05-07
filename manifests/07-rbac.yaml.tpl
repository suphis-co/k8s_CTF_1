apiVersion: v1
kind: ServiceAccount
metadata:
  name: intern-agent
  namespace: k8s-ctf
  labels:
    challenge: "07"
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: intern-agent-reader
  namespace: k8s-ctf
  labels:
    challenge: "07"
rules:
  - apiGroups: [""]
    resources: ["pods", "configmaps"]
    verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: intern-agent-reader
  namespace: k8s-ctf
  labels:
    challenge: "07"
subjects:
  - kind: ServiceAccount
    name: intern-agent
    namespace: k8s-ctf
roleRef:
  kind: Role
  name: intern-agent-reader
  apiGroup: rbac.authorization.k8s.io
---
apiVersion: v1
kind: Secret
metadata:
  name: manager-only
  namespace: k8s-ctf
  labels:
    challenge: "07"
type: Opaque
stringData:
  flag: __FLAG_07__
  hint: The intern-agent cannot read secrets. Your own kubectl identity probably can.
---
apiVersion: v1
kind: Pod
metadata:
  name: intern-terminal
  namespace: k8s-ctf
  labels:
    challenge: "07"
spec:
  serviceAccountName: intern-agent
  containers:
    - name: kubectl
      image: bitnami/kubectl:latest
      command: ["sh", "-c", "sleep 365d"]
