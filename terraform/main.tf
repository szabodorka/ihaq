provider "aws" {
  region = "eu-central-1"
}

module "vpc" {
    source = "./modules/vpc"
}

module "eks" {
  source = "./modules/eks"
  vpc_id = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_ids = module.vpc.public_subnet_ids
}

data "tls_certificate" "cluster" {
  url = module.eks.cluster_oidc_issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  url             = module.eks.cluster_oidc_issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster.certificates[0].sha1_fingerprint]

  depends_on = [ module.eks ]
}

resource "time_sleep" "wait_for_eks_api" {
  depends_on      = [module.eks]
  create_duration = "90s"
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
  depends_on = [time_sleep.wait_for_eks_api]
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }

  registry_config_path   = "${path.root}/.helm/registry.json"
  repository_cache       = "${path.root}/.helm/cache"
  repository_config_path = "${path.root}/.helm/repositories.yaml"
}

module "rds" {
  source = "./modules/rds"
  vpc_id = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  security_group_id = module.eks.node_security_group_id
  cluster_security_group_id = module.eks.cluster_security_group_id
}

module "lbc" {
    source = "./modules/lbc"
    cluster_oidc_issuer = module.eks.cluster_oidc_issuer
    cluster_name = module.eks.cluster_name
    openid_connect_provider = aws_iam_openid_connect_provider.eks.arn
    vpc_id = module.vpc.vpc_id

    depends_on = [
    aws_iam_openid_connect_provider.eks,
    time_sleep.wait_for_eks_api
    ]
}



