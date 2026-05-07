apiVersion: v1
kind: ConfigMap
metadata:
  name: unstable-app-config
  namespace: k8s-ctf
  labels:
    challenge: "06"
data:
  REQUIRED_MODE: production
  flag.txt: __FLAG_06__
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: unstable-app
  namespace: k8s-ctf
  labels:
    challenge: "06"
spec:
  replicas: 1
  selector:
    matchLabels:
      app: unstable-app
  template:
    metadata:
      labels:
        app: unstable-app
        challenge: "06"
    spec:
      containers:
        - name: unstable
          image: busybox:1.36
          command: ["sh", "-c"]
          args:
            - |
              echo "Starting unstable app..."
              echo "Mode is: ${APP_MODE:-unset}"
              if [ "${APP_MODE:-}" != "$REQUIRED_MODE" ]; then
                echo "Wrong APP_MODE. Expected $REQUIRED_MODE. Crashing now."
                exit 1
              fi
              echo "App stable. Flag is mounted at /etc/ctf/flag.txt"
              sleep 365d
          env:
            - name: REQUIRED_MODE
              valueFrom:
                configMapKeyRef:
                  name: unstable-app-config
                  key: REQUIRED_MODE
            - name: APP_MODE
              value: development
          volumeMounts:
            - name: unstable-config
              mountPath: /etc/ctf
      volumes:
        - name: unstable-config
          configMap:
            name: unstable-app-config
