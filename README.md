# verana-deploy-examples

Deployment examples for the Verana components, referenced by [docs.verana.io](https://docs.verana.io). Terraform first, with a CLI path in each provider README. Every folder states its status: `terraform validate` passes everywhere; "verified" appears with a date once an example has been applied end to end, and nothing carries that date yet.

```
vs-agent/
  compose/      VS Agent on one host: Docker Compose, Caddy for TLS, .env.example        (docs: Deploy on one VM)
  helm/         values.yaml + create-secrets.sh for the official chart                   (docs: Deploy on Kubernetes with Helm)
  aws-eks/      VPC, EKS, EBS CSI + gp3, ingress-nginx (NLB), cert-manager, Route 53     (docs: On AWS)
  gcp-gke/      GKE Autopilot, static address, ingress-nginx, cert-manager, Cloud DNS    (docs: On Google Cloud)
  azure-aks/    AKS, static IP, ingress-nginx, cert-manager, Azure DNS                   (docs: On Azure)
  ovh-mks/      Managed Kubernetes, node pool, ingress-nginx, cert-manager, OVH DNS      (docs: On OVHcloud)
modules/
  k8s-addons/   shared: ingress-nginx, cert-manager, ClusterIssuer letsencrypt-prod
node/vm/
  cloud-init.yaml.tftpl   one cloud-init for every provider (binary, genesis, peers, snapshot, systemd)
  aws/ gcp/ azure/ ovh/   VM, data volume, firewall, static address                      (docs: Node on a cloud VM)
indexer/helm/   values for the indexer chart                                             (docs: Run the indexer)
graph/helm/     values for the graph and the search charts                               (docs: Run the graph and search)
frontend/helm/  values for the frontend chart                                            (docs: Run the frontend)
```

## Conventions

- The Verana charts hardcode `ingressClassName: nginx` and `cert-manager.io/cluster-issuer: letsencrypt-prod`; the shared module creates exactly those, and the CLI paths do the same by hand.
- Charts create no Secret. The mnemonic and database passwords live in a pre-existing Secret, referenced through `extraEnv` or `existingSecret`/`pwdSecret`.
- Placeholders are written `<like this>` and `example.com`; nothing in this repository is a real identifier.
- Terraform state is local by default; add a backend before using an example for anything but a trial.

## Checks

CI runs `terraform fmt -check` and `terraform validate` on every folder, shellcheck on the scripts, a YAML parse of every file, and `docker compose config` on the Compose example. The same checks run locally with Terraform or OpenTofu.

Licence: Apache-2.0.
