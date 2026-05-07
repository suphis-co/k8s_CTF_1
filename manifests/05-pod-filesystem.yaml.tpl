apiVersion: v1
kind: Pod
metadata:
  name: archive-reader
  namespace: k8s-ctf
  labels:
    challenge: "05"
spec:
  restartPolicy: Always
  initContainers:
    - name: archive-writer
      image: busybox:1.36
      command: ["sh", "-c"]
      args:
        - |
          mkdir -p /archive/deep/path
          echo "__FLAG_05__" > /archive/deep/path/flag.txt
      volumeMounts:
        - name: archive
          mountPath: /archive
  containers:
    - name: reader
      image: busybox:1.36
      command: ["sh", "-c", "echo 'Archive reader online. Nothing to see here.'; sleep 365d"]
      volumeMounts:
        - name: archive
          mountPath: /archive
  volumes:
    - name: archive
      emptyDir: {}
