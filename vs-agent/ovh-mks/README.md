# VS Agent on OVHcloud (Managed Kubernetes)

The Verana testnet services run on OVHcloud Managed Kubernetes, so this is the most exercised path: a cluster in a Public Cloud project, a node pool, ingress-nginx behind an OVHcloud load balancer, cert-manager with the `letsencrypt-prod` issuer, and an A record in an OVHcloud DNS zone. Companion of the "[On OVHcloud (Managed Kubernetes)](https://docs.verana.io/docs/build/verifiable-services/cloud-ovh)" guide.

## Terraform

Prerequisites: Terraform 1.6 or later, a Public Cloud project, API credentials in `OVH_APPLICATION_KEY`, `OVH_APPLICATION_SECRET` and `OVH_CONSUMER_KEY` with rights on `/cloud/project/*` and `/domain/zone/*`, the domain's DNS zone managed at OVHcloud.

```bash
cp terraform.tfvars.example terraform.tfvars   # edit it
terraform init
terraform apply
terraform output -raw kubeconfig > agents.kubeconfig
KUBECONFIG=agents.kubeconfig kubectl get nodes
```

Then install the agent with the values of [`../helm`](../helm); the storage class default (`csi-cinder-high-speed`) already matches.

## CLI path

In the Public Cloud control panel: create a Managed Kubernetes cluster in your region with a node pool of two `b3-8` nodes, download the kubeconfig. Then:

```bash
export KUBECONFIG=./agents.kubeconfig
helm upgrade --install ingress-nginx ingress-nginx --repo https://kubernetes.github.io/ingress-nginx \
  -n ingress-nginx --create-namespace
helm upgrade --install cert-manager cert-manager --repo https://charts.jetstack.io \
  -n cert-manager --create-namespace --set crds.enabled=true
kubectl apply -f - <<'YAML'
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata: { name: letsencrypt-prod }
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: ops@example.com
    privateKeySecretRef: { name: letsencrypt-prod-account-key }
    solvers: [ { http01: { ingress: { ingressClassName: nginx } } } ]
YAML

kubectl -n ingress-nginx get svc ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
# create an A record agent.example.com -> that IP in the OVHcloud DNS zone
```

## Notes

- OVHcloud has no managed secret store integrated with Kubernetes; create Secrets from your pipeline or run External Secrets Operator against a vault you operate. `../helm/create-secrets.sh` is the minimal version.
- The load balancer is billed by the hour; a single VPS with the Compose example (`../compose`) is the cheaper option for one agent.

Status: `terraform validate` passes; not yet applied against a real project.
