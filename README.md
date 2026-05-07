# Capture the Flag: Kubernetes Edition

Een hands-on Kubernetes workshop waarin deelnemers flags vinden door echte Kubernetes-resources te inspecteren, debuggen en herstellen.

Deze versie is geschikt voor deelnemers die de repo zelf clonen: echte flags staan niet in GitHub. `./scripts/start.sh` genereert random flags, deployt ze naar Kubernetes en toont een encrypted submission blob die alleen de facilitator kan decrypten.

## Doelgroep

Beginners tot intermediate Kubernetes-gebruikers die willen oefenen met:

- `kubectl get`, `describe`, `logs`, `exec`
- ConfigMaps en Secrets
- Jobs en Pods
- Services, labels en selectors
- Init containers en volumes
- CrashLoopBackOff debugging
- RBAC en ServiceAccounts

## Vereisten

- Een werkende Kubernetes-cluster, bijvoorbeeld `kind`, `minikube`, Docker Desktop Kubernetes of een cloudcluster
- `kubectl`
- `openssl`
- `base64`
- Toegang om resources in een namespace aan te maken

Optioneel handig:

- `curl`

## Facilitator setup

De repo bevat alleen een public key in `keys/facilitator_public.pem`. De bijbehorende private key moet buiten GitHub blijven.

Nieuwe keypair maken:

```bash
./scripts/setup-facilitator-keys.sh
```

Commit daarna alleen de public key:

```bash
git add keys/facilitator_public.pem
git commit -m "Add facilitator public key"
```

Nooit committen:

```text
keys/facilitator_private.pem
.generated/
```

## Snel starten voor deelnemers

```bash
git clone <jouw-repo-url>
cd k8s-ctf-workshop
./scripts/start.sh
```

Het script toont een encrypted submission blob. Stuur die naar de facilitator. De blob bevat de random flags voor jouw run, maar alleen de facilitator kan hem decrypten.

Controleer de omgeving:

```bash
kubectl get all -n k8s-ctf
```

Verwachte startstatus:

```text
archive-reader        Running
ctf-web-*             Running
forensic-printer-*    Completed
intern-terminal       Running
unstable-app-*        Error of CrashLoopBackOff
```

Resetten:

```bash
./scripts/reset.sh
```

## Submission blob decrypten als facilitator

Sla de blob op in bijvoorbeeld `submission.txt` en run:

```bash
./scripts/decrypt-submission.sh /pad/naar/facilitator_private.pem submission.txt
```

Of via stdin:

```bash
cat submission.txt | ./scripts/decrypt-submission.sh /pad/naar/facilitator_private.pem
```



## Spelregels voor deelnemers

1. Echte flags hebben het formaat `K8SCTF{...}`.
2. Gebruik `kubectl` en standaard shell tools.
3. Repo-flags en decoys tellen niet. Alleen flags die via Kubernetes uit de cluster komen zijn geldig.
4. Kijk niet in de map `solutions` totdat je klaar bent.
5. Je mag resources inspecteren, logs lezen, pods exec'en en kapotte configs patchen.
6. Je hoeft geen extra images te bouwen.

## Waarom staan er nepflags in de repo?

Dat is expres. `decoys.yaml` en sommige templates bevatten lokvlaggen. De echte flags worden pas door `start.sh` gegenereerd en direct in de cluster geplaatst.

## Missies

### Missie 1: Mission Briefing

Er is een briefing achtergelaten in de namespace `k8s-ctf`.

Startpunt:

```bash
kubectl get configmaps -n k8s-ctf
```

Doel: vind flag 1.

Hint:

```bash
kubectl describe configmap <naam> -n k8s-ctf
```

---

### Missie 2: The Vault

Een Kubernetes Secret bevat gevoelige informatie. Is die echt geheim?

Startpunt:

```bash
kubectl get secrets -n k8s-ctf
```

Doel: vind en decodeer flag 2.

Hint:

```bash
kubectl get secret <naam> -n k8s-ctf -o yaml
```

---

### Missie 3: Forensic Logs

Een Job heeft bewijs geprint en is daarna gestopt.

Startpunt:

```bash
kubectl get jobs,pods -n k8s-ctf
```

Doel: vind flag 3 in logs.

Hint:

```bash
kubectl logs job/<jobnaam> -n k8s-ctf
```

---

### Missie 4: Broken Web Service

Er draait een webapp, maar de Service stuurt verkeer nergens heen.

Startpunt:

```bash
kubectl get deploy,svc,endpoints -n k8s-ctf
kubectl describe svc ctf-web -n k8s-ctf
```

Doel: repareer de Service en bezoek `/flag`.

Na reparatie:

```bash
kubectl port-forward svc/ctf-web 8080:80 -n k8s-ctf
curl http://localhost:8080/flag
```

Hint: vergelijk labels van de Pods met de selector van de Service.

---

### Missie 5: Archive Reader

Een initContainer heeft een bestand geschreven voordat de hoofdcontainer startte.

Startpunt:

```bash
kubectl get pod archive-reader -n k8s-ctf
kubectl describe pod archive-reader -n k8s-ctf
```

Doel: vind flag 5 in het volume.

Hint:

```bash
kubectl exec -n k8s-ctf archive-reader -- find /archive -maxdepth 5 -type f
```

---

### Missie 6: CrashLoopBackOff

Een deployment blijft crashen door een verkeerde configuratie.

Startpunt:

```bash
kubectl get pods -n k8s-ctf
kubectl logs deploy/unstable-app -n k8s-ctf
```

Doel: fix de deployment zodat de pod blijft draaien en lees de flag uit `/etc/ctf/flag.txt`.

Hint: de app verwacht een specifieke `APP_MODE`.

---

### Missie 7: RBAC Reality Check

Een ServiceAccount mag sommige dingen wel lezen en andere niet.

Startpunt:

```bash
kubectl exec -n k8s-ctf intern-terminal -- kubectl auth can-i list pods
kubectl exec -n k8s-ctf intern-terminal -- kubectl auth can-i get secrets
```

Doel: ontdek wat `intern-agent` niet mag en vind de manager-only flag met je eigen kubectl-rechten.

Hint:

```bash
kubectl get role,rolebinding,sa -n k8s-ctf
kubectl describe role intern-agent-reader -n k8s-ctf
```

## Workshop-flow, 60 tot 90 minuten

| Tijd | Onderdeel |
|---:|---|
| 5 min | Intro: namespace, flags, spelregels |
| 10 min | Missie 1 en 2: ConfigMaps en Secrets |
| 10 min | Missie 3: Jobs en logs |
| 15 min | Missie 4: labels, selectors en Services |
| 10 min | Missie 5: initContainers en volumes |
| 15 min | Missie 6: CrashLoopBackOff debugging |
| 10 min | Missie 7: RBAC |
| 5 min | Nabespreking en security-lessons |
