apiVersion: batch/v1
kind: Job
metadata:
  name: forensic-printer
  namespace: k8s-ctf
  labels:
    challenge: "03"
spec:
  template:
    metadata:
      labels:
        app: forensic-printer
        challenge: "03"
    spec:
      restartPolicy: Never
      containers:
        - name: printer
          image: busybox:1.36
          command: ["sh", "-c"]
          args:
            - |
              echo "Booting forensic printer..."
              echo "Collecting evidence..."
              echo "__FLAG_03__"
              echo "Printer finished."
  backoffLimit: 0
