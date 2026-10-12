# verana-deploy-examples

Deployment examples for the Verana components, referenced by [docs.verana.io](https://docs.verana.io). Terraform first, with a short CLI path per provider. Each folder has its own README with a **verified** date; an example without a date has not been run end to end yet.

```
vs-agent/
  compose/      VS Agent on one host: Docker Compose, Caddy for TLS, .env.example      (docs: Deploy on one VM)
  helm/         values.yaml for the official chart                                     (docs: Deploy on Kubernetes with Helm)
  aws-eks/      cluster, ingress-nginx, cert-manager, Route 53, then the Helm install  (docs: On AWS)
  gcp-gke/      same on Google Cloud                                                   (docs: On Google Cloud)
  azure-aks/    same on Azure                                                          (docs: On Azure)
  ovh-mks/      same on OVHcloud Managed Kubernetes, what Verana runs on               (docs: On OVHcloud)
node/
  vm/           a full node or validator on a VM, per provider                         (docs: Node on a cloud VM)
indexer/helm/   values for the indexer chart
graph/helm/     values for the graph and search charts
frontend/helm/  values for the frontend chart
```

Status: the Compose example is the one the documentation quickstart uses. The Helm values and the provider folders are being assembled; each README states what is in place.

Licence: Apache-2.0.
