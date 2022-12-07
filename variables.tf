variable "cluster_name" {}

variable "aws_region" {
  default = ""
}

variable "map_users" {
  description = <<-EOF
    Additional IAM users to add to the aws-auth configmap.
    By default only the IAM user who created the cluster has permissions to access Kubernetes API (i.e. use kubectl).
    Add here other users who also should be allowed to do it.
  EOF
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = []
}

variable "kubernetes_version" {
  default = "1.19"
}

variable "autoscaler_chart_version" {
  default = "9.9.2"
}

variable "autoscaler_version" {
  default = "1.20.3"
}

variable "map_roles" {
  description = <<-EOF
    Additional IAM roles to add to the aws-auth configmap.
    By default only the IAM user who created the cluster has permissions to access Kubernetes API (i.e. use kubectl).
    Add here other roles who also should be allowed to do it.
  EOF
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = []
}

variable "worker_groups" {
  default = [
    {
      name                          = "worker-group-medium"
      instance_type                 = "t3.medium"
      additional_userdata           = ""
      root_volume_type              = "gp2"

      #autoscaling group section
      asg_max_size                  = "5"
      asg_desired_capacity          = "1"
    },
    {
      name                          = "worker-group-large"
      instance_type                 = "t3.xlarge"
      additional_userdata           = ""
      root_volume_type              = "gp2"

      #autoscaling group section
      asg_max_size         = "8"
      asg_desired_capacity = "3"
    },
  ]
}

variable "allow_cloudwatch" {
  type = bool
  default = false
  description = "Whether to create the required policies to read/write CloudWatch Metrics"
}
