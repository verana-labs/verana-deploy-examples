# Verana node on an EC2 instance in the default VPC: Ubuntu 24.04, gp3 data volume, security group,
# Elastic IP, cloud-init from ../cloud-init.yaml.tftpl.

provider "aws" {
  region = var.region
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

resource "aws_key_pair" "node" {
  key_name   = var.name
  public_key = var.ssh_public_key
}

resource "aws_security_group" "node" {
  name        = var.name
  description = "Verana node"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.admin_cidrs
  }

  ingress {
    description = "P2P"
    from_port   = 26656
    to_port     = 26656
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  dynamic "ingress" {
    for_each = var.expose_rpc && length(var.rpc_cidrs) > 0 ? { rpc = 26657, rest = 1317 } : {}
    content {
      description = ingress.key
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = var.rpc_cidrs
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = var.name }
}

resource "aws_instance" "node" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.node.id]
  key_name                    = aws_key_pair.node.key_name
  associate_public_ip_address = true

  root_block_device {
    volume_type = "gp3"
    volume_size = 50
  }

  user_data = templatefile("${path.module}/../cloud-init.yaml.tftpl", {
    chain_id     = var.chain_id
    moniker      = var.moniker
    peers_file   = local.peers_file
    expose_rpc   = var.expose_rpc
    pruned       = var.pruned
    use_snapshot = var.use_snapshot
    data_device  = "/dev/nvme1n1"
  })

  tags = { Name = var.name }
}

resource "aws_ebs_volume" "data" {
  availability_zone = aws_instance.node.availability_zone
  size              = var.data_disk_gb
  type              = "gp3"
  encrypted         = true

  tags = { Name = "${var.name}-data" }
}

resource "aws_volume_attachment" "data" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.data.id
  instance_id = aws_instance.node.id
}

resource "aws_eip" "node" {
  instance = aws_instance.node.id
  domain   = "vpc"

  tags = { Name = var.name }
}
