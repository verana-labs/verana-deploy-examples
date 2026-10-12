# Verana node on OVHcloud (Public Cloud instance)

A `b3-16` Ubuntu 24.04 instance on Ext-Net, a 200 GB high-speed block volume mounted at `/var/lib/verana`, a security group (SSH from `admin_cidrs`, 26656 open, 26657 and 1317 from `rpc_cidrs` when `expose_rpc` is true), and the shared cloud-init. OVHcloud Public Cloud is driven through its OpenStack API: download the OpenRC file of an OpenStack user of your project and `source openrc.sh` before `terraform apply`. See [`../README.md`](../README.md) for the common variables.

```bash
source ~/openrc.sh
cp terraform.tfvars.example terraform.tfvars   # edit it
terraform init && terraform apply
ssh ubuntu@$(terraform output -raw public_ip) sudo journalctl -u veranad -f
```

Snapshots: volume snapshots from the control panel or `openstack volume snapshot create`; a dedicated server is the alternative for a long-lived validator.

Status: `terraform validate` passes; not yet applied against a real project.
