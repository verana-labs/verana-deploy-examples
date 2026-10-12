variable "region" {
  description = "AWS region."
  type        = string
  default     = "eu-west-1"
}

variable "instance_type" {
  description = "m6i.xlarge (4 vCPU, 16 GB) for a validator; m6i.large is enough for a pruned full node."
  type        = string
  default     = "m6i.xlarge"
}

variable "name" {
  description = "Name tag of the resources."
  type        = string
  default     = "verana-node"
}
