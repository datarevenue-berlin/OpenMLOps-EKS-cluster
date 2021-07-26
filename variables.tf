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


variable "eks_worker_groups" {
  description = "Definition of AWS worker groups to be utilized."
  type = list(object({
    name = string
    instance_type = string
    additional_userdata = string
    root_volume_type              = string
    asg_max_size                  = string
    asg_desired_capacity          = string
	}))
 }

variable "kubernetes_version" {
    type = string
}