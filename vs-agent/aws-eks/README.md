# VS Agent on AWS (EKS)

Everything specific to AWS happens before the Helm install: a VPC, an EKS cluster with one managed node group, the EBS CSI driver with a `gp3` storage class, ingress-nginx behind a Network Load Balancer, cert-manager with the `letsencrypt-prod` issuer, and a Route 53 record. Companion of the "[On AWS (EKS)](https://docs.verana.io/docs/build/verifiable-services/cloud-aws)" guide.

## Terraform

Prerequisites: Terraform 1.6 or later, the AWS CLI with credentials that can create VPCs, EKS clusters and IAM roles, a Route 53 hosted zone for your domain.

```bash
cp terraform.tfvars.example terraform.tfvars   # edit it
terraform init
terraform apply
$(terraform output -raw kubeconfig_command)
kubectl get nodes
```

Then install the agent with the values of [`../helm`](../helm) and `storage.storageClassName: gp3`.

The apply takes about 20 minutes, most of it the cluster. `terraform destroy` removes everything including the load balancer; delete the agent's namespace first so Kubernetes releases the volumes.

## CLI path

The same result by hand:

```bash
eksctl create cluster --name agents --region eu-west-1 --nodes 2 --node-type t3.medium
eksctl create addon --name aws-ebs-csi-driver --cluster agents --region eu-west-1
kubectl apply -f - <<'YAML'
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata: { name: gp3 }
provisioner: ebs.csi.aws.com
parameters: { type: gp3 }
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
YAML

helm upgrade --install ingress-nginx ingress-nginx --repo https://kubernetes.github.io/ingress-nginx \
  -n ingress-nginx --create-namespace \
  --set controller.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-type"=nlb
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

kubectl -n ingress-nginx get svc ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
# create a CNAME agent.example.com -> that hostname in Route 53
```

## Notes

- Keep the admin API internal (the chart default). Your backend runs in the same cluster or VPC and reaches `http://agent.agents.svc:3000`.
- Secrets: the mnemonic belongs in AWS Secrets Manager synced with External Secrets Operator, or in a Secret created by your pipeline. `../helm/create-secrets.sh` is the minimal version.
- Cost: two `t3.medium` nodes, one NAT gateway and one NLB are the whole bill for a handful of agents.

Status: `terraform validate` passes; not yet applied against a real account.
