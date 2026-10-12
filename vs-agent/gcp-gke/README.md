# VS Agent on Google Cloud (GKE)

An Autopilot cluster, a reserved external address, ingress-nginx bound to it, cert-manager with the `letsencrypt-prod` issuer, and a Cloud DNS record. Companion of the "[On Google Cloud (GKE)](https://docs.verana.io/docs/build/verifiable-services/cloud-gcp)" guide.

## Terraform

Prerequisites: Terraform 1.6 or later, `gcloud auth application-default login` with a role that can create clusters and DNS records, a Cloud DNS managed zone for your domain. The `gke-gcloud-auth-plugin` component is needed for `kubectl` afterwards.

```bash
cp terraform.tfvars.example terraform.tfvars   # edit it
terraform init
terraform apply
$(terraform output -raw kubeconfig_command)
kubectl get nodes
```

Then install the agent with the values of [`../helm`](../helm) and `storage.storageClassName: standard-rwo`.

## CLI path

```bash
gcloud container clusters create-auto agents --region europe-west1
gcloud compute addresses create agents-ingress --region europe-west1
IP=$(gcloud compute addresses describe agents-ingress --region europe-west1 --format='value(address)')

helm upgrade --install ingress-nginx ingress-nginx --repo https://kubernetes.github.io/ingress-nginx \
  -n ingress-nginx --create-namespace --set controller.service.loadBalancerIP="$IP"
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

gcloud dns record-sets create agent.example.com. --zone example-com --type A --ttl 300 --rrdatas "$IP"
```

## Notes

- Autopilot bills per pod resources; the agent's requests are small. Autopilot can take a few minutes to schedule the first pods while it provisions capacity.
- Secrets: Secret Manager plus External Secrets Operator, or a Secret created by Cloud Build. `../helm/create-secrets.sh` is the minimal version.

Status: `terraform validate` passes; not yet applied against a real project.
