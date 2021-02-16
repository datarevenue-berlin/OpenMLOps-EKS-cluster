# AWS EKS cluster for MLOps Reference Architecture

This is a Terraform module that provisions and configures an AWS EKS Kubernetes cluster, so that it's prepared 
for installing [MLOps Reference Architecture](https://github.com/datarevenue-berlin/mlops-architecture) 
tools in it.

## Other repositories

This configuration doesn't install the tools, it just provisions the cluster. Check out other repositories
for the MLOps tools.

![Repositories diagram](http://www.plantuml.com/plantuml/svg/fP9DImCn48Rl-HL3BvxIlHUH5l4WLHGgU2WzfDcn2StEB9b9FOZ_tTHI55a_fEV9Ey_3EvcAkgobIyOd9mAZsvkxNc2MVOYANaj6O8BPus84BmRWFlCkIcGISE1J4SKCZbg89EfI4ZWiKEOaunfOBeDgBvEcsKGDPJtst3MjgrJS8HMqQymfKjCbxiMwJrpBPDspG9rkORKoh-PxnuFSzO135Qkcyr8nX8fob3xDxKzIS3LVmEK1zxMzGISe4cdp7XFCk-WH-6dV_Ob5ubRi4V4XJgm8EMw2ceSG1JBsR91Qs0-C-Uadd5ixU8L_X8PRCcVAu9aqSm8D29nRp1CpU7Ax3B5jaLONl-yrzIc2ZzadD5EajdJf3G00)

## Provisioned resources

This configuration will provision:
- a VPC to isolate the cluster resources
- an EKS cluster with one node group
- security groups needed for the tools to communicate with each other and with the outside world
- a policy to allow the worker nodes access to S3 storage and ECR registry
