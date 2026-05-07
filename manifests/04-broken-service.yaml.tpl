apiVersion: v1
kind: ConfigMap
metadata:
  name: ctf-web-app
  namespace: k8s-ctf
  labels:
    challenge: "04"
data:
  server.py: |
    from http.server import BaseHTTPRequestHandler, HTTPServer
    import os

    FLAG = os.environ.get("FLAG_FOUR", "missing flag")

    class Handler(BaseHTTPRequestHandler):
        def do_GET(self):
            if self.path == "/flag":
                body = f"{FLAG}\n"
            else:
                body = "Kubernetes CTF web service. Try /flag\n"
            self.send_response(200)
            self.send_header("Content-Type", "text/plain")
            self.send_header("Content-Length", str(len(body.encode())))
            self.end_headers()
            self.wfile.write(body.encode())

    HTTPServer(("0.0.0.0", 8080), Handler).serve_forever()
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ctf-web
  namespace: k8s-ctf
  labels:
    challenge: "04"
spec:
  replicas: 2
  selector:
    matchLabels:
      app: ctf-web
  template:
    metadata:
      labels:
        app: ctf-web
        challenge: "04"
    spec:
      containers:
        - name: web
          image: python:3.12-alpine
          command: ["python", "/app/server.py"]
          ports:
            - containerPort: 8080
          env:
            - name: FLAG_FOUR
              value: __FLAG_04__
          volumeMounts:
            - name: app
              mountPath: /app
      volumes:
        - name: app
          configMap:
            name: ctf-web-app
---
apiVersion: v1
kind: Service
metadata:
  name: ctf-web
  namespace: k8s-ctf
  labels:
    challenge: "04"
spec:
  selector:
    app: ctf-web-broken
  ports:
    - name: http
      port: 80
      targetPort: 8080
