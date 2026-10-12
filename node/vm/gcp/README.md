# Verana node on Google Cloud (Compute Engine)

An `n2-standard-4` Ubuntu 24.04 instance in the default network, a 200 GB `pd-ssd` data disk mounted at `/var/lib/verana`, firewall rules by network tag (SSH from `admin_cidrs`, 26656 open, 26657 and 1317 from `rpc_cidrs` when `expose_rpc` is true), a static external address, and the shared cloud-init. See [`../README.md`](../README.md) for the common variables.

```bash
cp terraform.tfvars.example terraform.tfvars   # edit it
terraform init && terraform apply
ssh ubuntu@$(terraform output -raw public_ip) sudo journalctl -u veranad -f
```

Snapshots: attach a snapshot schedule to the data disk (`gcloud compute disks add-resource-policies`).

Status: `terraform validate` passes; not yet applied against a real project.
