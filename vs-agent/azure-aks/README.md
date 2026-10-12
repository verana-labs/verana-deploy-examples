# VS Agent on Azure (AKS)

A resource group, an AKS cluster with two small nodes, a static public IP, ingress-nginx bound to it, cert-manager with the `letsencrypt-prod` issuer, and an Azure DNS record. Companion of the "[On Azure (AKS)](https://docs.verana.io/docs/build/verifiable-services/cloud-azure)" guide.

## Terraform

Prerequisites: Terraform 1.6 or later, `az login` with Contributor on the subscription, an Azure DNS zone for your domain (its resource group goes in `dns_zone_resource_group`).

```bash
cp terraform.tfvars.example terraform.tfvars   # edit it
terraform init
terraform apply
$(terraform output -raw kubeconfig_command)
kubectl get nodes
```

Then install the agent with the values of [`../helm`](../helm) and `storage.storageClassName: managed-csi`.

## CLI path

```bash
az group create --name agents --location westeurope
az aks create --resource-group agents --name agents --node-count 2 --node-vm-size Standard_B2s --generate-ssh-keys
az aks get-credentials --resource-group agents --name agents
NODE_RG=$(az aks show --resource-group agents --name agents --query nodeResourceGroup -o tsv)
az network public-ip create --resource-group "$NODE_RG" --name agents-ingress --sku Standard --allocation-method static
IP=$(az network public-ip show --resource-group "$NODE_RG" --name agents-ingress --query ipAddress -o tsv)

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

az network dns record-set a add-record --resource-group dns --zone-name example.com --record-set-name agent --ipv4-address "$IP"
```

## Notes

- Secrets: Key Vault with the Secrets Store CSI driver, or External Secrets Operator. `../helm/create-secrets.sh` is the minimal version.
- The example uses the cluster's local admin credentials for Terraform's Kubernetes providers; switch to Entra ID integration for a shared production cluster.

Status: `terraform validate` passes; not yet applied against a real subscription.
