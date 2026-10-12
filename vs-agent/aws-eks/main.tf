# EKS cluster for VS Agents: VPC, cluster with a managed node group, EBS CSI driver with a
# gp3 storage class, ingress-nginx behind a Network Load Balancer, cert-manager, Route 53 record.

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 2)
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.17"

  name = var.cluster_name
  cidr = "10.0.0.0/16"

  azs             = local.azs
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags  = { "kubernetes.io/role/elb" = 1 }
  private_subnet_tags = { "kubernetes.io/role/internal-elb" = 1 }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  cluster_name    = var.cluster_name
  cluster_version = var.kubernetes_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  cluster_addons = {
    coredns    = {}
    kube-proxy = {}
    vpc-cni    = {}
    aws-ebs-csi-driver = {
      service_account_role_arn = module.ebs_csi_irsa.iam_role_arn
    }
  }

  eks_managed_node_groups = {
    default = {
      instance_types = [var.node_instance_type]
      min_size       = var.node_count
      max_size       = var.node_count + 1
      desired_size   = var.node_count
    }
  }
}

module "ebs_csi_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.52"

  role_name             = "${var.cluster_name}-ebs-csi"
  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}

# gp3 storage class for the agent and database volumes (set storage.storageClassName: gp3).
resource "kubernetes_storage_class_v1" "gp3" {
  depends_on = [module.eks]

  metadata {
    name = "gp3"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }
  storage_provisioner    = "ebs.csi.aws.com"
  reclaim_policy         = "Retain"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true
  parameters = {
    type      = "gp3"
    encrypted = "true"
  }
}

module "addons" {
  source     = "../../modules/k8s-addons"
  depends_on = [module.eks]

  acme_email = var.acme_email
  load_balancer_annotations = {
    "service.beta.kubernetes.io/aws-load-balancer-type"   = "nlb"
    "service.beta.kubernetes.io/aws-load-balancer-scheme" = "internet-facing"
  }
}

data "aws_route53_zone" "zone" {
  name = var.dns_zone_name
}

resource "aws_route53_record" "agent" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = var.agent_hostname
  type    = "CNAME"
  ttl     = 300
  records = [module.addons.load_balancer_hostname]
}
