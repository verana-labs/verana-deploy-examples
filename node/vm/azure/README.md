# Verana node on Azure (Virtual Machines)

A resource group with a VNet, a network security group (SSH from `admin_cidrs`, 26656 open, 26657 and 1317 from `rpc_cidrs` when `expose_rpc` is true), a static public IP, a `Standard_D4s_v5` Ubuntu 24.04 VM, a 200 GB Premium SSD data disk at LUN 0 mounted at `/var/lib/verana`, and the shared cloud-init. See [`../README.md`](../README.md) for the common variables.

```bash
cp terraform.tfvars.example terraform.tfvars   # edit it
terraform init && terraform apply
ssh ubuntu@$(terraform output -raw public_ip) sudo journalctl -u veranad -f
```

Snapshots: Azure Backup with a daily policy on the VM, or incremental snapshots of the data disk.

Status: `terraform validate` passes; not yet applied against a real subscription.
