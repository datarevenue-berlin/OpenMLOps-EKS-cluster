variable "cluster_name" {}

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
