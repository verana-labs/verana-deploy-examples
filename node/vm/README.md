# Verana node on a cloud VM

A full node or a validator runs on a plain virtual machine; Kubernetes adds nothing for a single node. One cloud-init template ([`cloud-init.yaml.tftpl`](./cloud-init.yaml.tftpl)) installs the published `veranad` binary, initialises the home on a dedicated data volume, downloads genesis, sets peers and gas price, optionally restores the latest snapshot, and starts a systemd service. Each provider folder creates the VM, the data volume, the firewall and a static address, and renders that template. Companion of the "[Node on a cloud VM](https://docs.verana.io/docs/build/run-infrastructure/node-on-a-cloud-vm)" guide.

| | Full node (RPC for your own services) | Validator |
|---|---|---|
| CPU, memory | 4 vCPU, 8 GB | 4 vCPU, 16 GB |
| Disk | 200 GB SSD data volume, grows with chain history | same, plus backups of the key material |
| Network | 26656 open; 26657 and 1317 only to your services | 26656 to your sentries only; no public RPC |

| Folder | Default size | Data device seen by the VM |
|---|---|---|
| [`aws`](./aws) | `m6i.xlarge`, `gp3` | `/dev/nvme1n1` |
| [`gcp`](./gcp) | `n2-standard-4`, `pd-ssd` | `/dev/disk/by-id/google-data` |
| [`azure`](./azure) | `Standard_D4s_v5`, Premium SSD | `/dev/disk/azure/scsi1/lun0` |
| [`ovh`](./ovh) | `b3-16`, `high-speed` volume | `/dev/disk/by-id/virtio-<volume id>` |

Common variables: `chain_id` (`vna-testnet-1`), `moniker`, `expose_rpc` (opens 26657 and 1317 to `rpc_cidrs`), `pruned`, `use_snapshot`, `admin_cidrs` for SSH, an SSH public key.

After `terraform apply`:

```bash
ssh ubuntu@$(terraform output -raw public_ip)
sudo journalctl -u veranad -f
curl -s localhost:26657/status | jq .result.sync_info
```

For a validator, continue with "[Become a validator](https://docs.verana.io/docs/build/run-infrastructure/run-a-node/join-validator)" and the sentry architecture; the validator's own 26657 and 1317 stay closed (`expose_rpc = false`).

Status: cloud-init follows the join-testnet guide step by step; the Terraform of each folder passes `terraform validate` but has not yet been applied against a real account.
