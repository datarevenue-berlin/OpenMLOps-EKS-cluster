data "aws_availability_zones" "available" {}


module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name                 = var.cluster_name
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
}



module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = var.cluster_name
  cluster_version = "1.17"
  subnets         = module.vpc.private_subnets

  tags = {
    Environment       = "development"
  }

  vpc_id    = module.vpc.vpc_id
  map_users = var.map_users

  worker_groups = [
    {
      name                          = "worker-group-medium"
      instance_type                 = "t3.medium"
      additional_userdata           = ""
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
      root_volume_type              = "gp2"

      #autoscaling group section
      asg_max_size                  = "5"
      asg_desired_capacity          = "1"
    },
    {
      name                          = "worker-group-large"
      instance_type                 = "t3.xlarge"
      additional_userdata           = ""
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_two.id]
      root_volume_type              = "gp2"

      #autoscaling group section
      asg_max_size         = "8"
      asg_desired_capacity = "3"
    },

  ]
}


data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}


data "http" "worker_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.9/docs/examples/iam-policy.json"

  request_headers = {
    Accept = "application/json"
  }
}

resource "aws_iam_role_policy" "worker_policy" {
  name   = "worker_policy"
  role   = module.eks.worker_iam_role_name
  policy = data.http.worker_policy.body
}

resource "aws_iam_role_policy_attachment" "ec2_container_reg_full_access" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
  role       = module.eks.worker_iam_role_name
}

resource "aws_iam_role_policy_attachment" "s3_full_access" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = module.eks.worker_iam_role_name
}

resource "aws_iam_role_policy_attachment" "workers_autoscaling" {
  policy_arn = aws_iam_policy.worker_autoscaling.arn
  role       = module.eks.worker_iam_role_name
}

resource "aws_iam_policy" "worker_autoscaling" {
  name_prefix = "eks-worker-autoscaling-${module.eks.cluster_id}"
  description = "EKS worker node autoscaling policy for cluster ${module.eks.cluster_id}"
  policy      = data.aws_iam_policy_document.worker_autoscaling.json
}

data "aws_iam_policy_document" "worker_autoscaling" {
  statement {
    sid    = "eksWorkerAutoscalingAll"
    effect = "Allow"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "ec2:DescribeLaunchTemplateVersions",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "eksWorkerAutoscalingOwn"
    effect = "Allow"

    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:UpdateAutoScalingGroup",
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/kubernetes.io/cluster/${module.eks.cluster_id}"
      values   = ["owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/enabled"
      values   = ["true"]
    }
  }
}


resource "helm_release" "autoscaler" {
  repository = "https://kubernetes.github.io/autoscaler"
  name       = "autoscaler"
  chart      = "cluster-autoscaler"
  version    = "9.9.2"
  namespace  = "kube-system"
  depends_on = [aws_iam_role_policy_attachment.workers_autoscaling]

  set {
    name  = "awsRegion"
    value = var.aws_region
  }
  set {
    name  = "autoDiscovery.clusterName"
    value = var.cluster_name
  }
  set {
    name = "rbac.create"
    value = true
  }
  set {
    name = "image.tag"
    value = "v1.17.4"
  }
}