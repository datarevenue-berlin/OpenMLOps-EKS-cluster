# AWS EKS cluster for MLOps Reference Architecture

This is a Terraform module that sets up an AWS EKS Kubernetes cluster for you, so that it's prepared 
for installing [MLOps Reference Architecture](https://github.com/datarevenue-berlin/mlops-architecture) 
tools on it.

## Check a ready-to-use example

This module only provisions the cluster. It doesn't install the tools.

A complete example of Terraform configuration which sets up the cluster and installs MLOps tools in it
can be found [**here**](https://github.com/datarevenue-berlin/mlops-architecture-aws).

## Provisioned resources

This configuration will provision:
- a VPC to isolate the cluster resources
- an EKS cluster with one node group
- security groups needed for the tools to communicate with each other and with the outside world
- a policy to allow the worker nodes access to S3 storage and ECR registry
