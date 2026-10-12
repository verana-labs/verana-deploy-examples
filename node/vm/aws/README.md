# Verana node on AWS (EC2)

An `m6i.xlarge` Ubuntu 24.04 instance in the default VPC, a 200 GB `gp3` data volume mounted at `/var/lib/verana`, a security group (SSH from `admin_cidrs`, 26656 open, 26657 and 1317 from `rpc_cidrs` when `expose_rpc` is true), an Elastic IP, and the shared cloud-init. See [`../README.md`](../README.md) for the common variables.

```bash
cp terraform.tfvars.example terraform.tfvars   # edit it
terraform init && terraform apply
ssh ubuntu@$(terraform output -raw public_ip) sudo journalctl -u veranad -f
```

Snapshots: enable daily EBS snapshots of the data volume with Amazon Data Lifecycle Manager on the `Name` tag.

Status: `terraform validate` passes; not yet applied against a real account.
