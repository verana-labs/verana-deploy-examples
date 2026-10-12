variable "chain_id" {
  description = "Network to join: vna-testnet-1 or vna-devnet-1."
  type        = string
  default     = "vna-testnet-1"
}

variable "moniker" {
  description = "Public name of the node."
  type        = string
  default     = "my-verana-node"
}

variable "expose_rpc" {
  description = "Serve RPC (26657) and REST (1317) to rpc_cidrs. Keep false on a validator."
  type        = bool
  default     = true
}

variable "rpc_cidrs" {
  description = "Networks allowed to reach 26657 and 1317 when expose_rpc is true."
  type        = list(string)
  default     = []
}

variable "admin_cidrs" {
  description = "Networks allowed to reach SSH."
  type        = list(string)
}

variable "ssh_public_key" {
  description = "SSH public key installed for the ubuntu user."
  type        = string
}

variable "pruned" {
  description = "Prune state (keep the last 100 heights). A full node keeps everything."
  type        = bool
  default     = false
}

variable "use_snapshot" {
  description = "Restore the latest published snapshot instead of syncing from genesis."
  type        = bool
  default     = true
}

variable "data_disk_gb" {
  description = "Size of the data volume in GB."
  type        = number
  default     = 200
}

variable "sentry_peers_only" {
  description = "Use the sentry-only peers list instead of the full persistent peers list."
  type        = bool
  default     = true
}

locals {
  peers_file = var.sentry_peers_only ? "sentry_peers.json" : "persistent_peers.json"
}
