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
