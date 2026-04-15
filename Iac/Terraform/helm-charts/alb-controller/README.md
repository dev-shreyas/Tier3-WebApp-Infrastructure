# ALB Controller Helm Chart Pipeline

This pipeline handles the provisioning and management of AWS Load Balancer (ALB) Controller using Terraform and Helm.

## Overview

The ALB Controller pipeline is **separated** from the main infrastructure pipeline to enable independent lifecycle management and state isolation. This allows:

- **Independent Updates**: Deploy ALB controller updates without affecting EKS infrastructure
- **Separate State**: Maintains a dedicated S3 backend state file for ALB resources
- **Team Separation**: Different teams can manage ALB configuration independently
- **Easier Rollbacks**: Service-specific rollbacks without impacting cluster infrastructure

## Architecture

```
helm-charts/
└── alb-controller/
    ├── backend.tf          # S3 backend configuration (separate state)
    ├── provider.tf         # AWS, Kubernetes, and Helm providers
    ├── var.tf              # Input variables
    ├── main.tf             # ALB IAM role, policy, and Helm release
    ├── out.tf              # Output values
    ├── alb_iam_policy.json # ALB controller IAM permissions
    └── envs/
        ├── dev.tfvars
        ├── uat.tfvars
        └── prod.tfvars
```

## S3 Backend State

The ALB controller state is stored in a **separate S3 backend**:

```
Bucket: flaskapp-terraform-state
Key: helm-charts/alb-controller/terraform.tfstate
Region: ap-south-1
Encryption: Enabled
Lock Table: terraform-locks
```

## Prerequisites

1. **EKS Cluster must be running** - ALB controller requires an active EKS cluster
2. **OIDC Provider configured** - For IRSA (IAM Roles for Service Accounts)
3. **Terraform state bucket** - Must be created with proper encryption and locking

## Usage

### Initialize Terraform

```bash
cd helm-charts/alb-controller
terraform init -backend-config="bucket=flaskapp-terraform-state" \
                 -backend-config="key=helm-charts/alb-controller/terraform.tfstate" \
                 -backend-config="region=ap-south-1"
```

### Plan for Environment

```bash
# Development
terraform plan -var-file="envs/dev.tfvars" -out=tfplan-dev

# UAT
terraform plan -var-file="envs/uat.tfvars" -out=tfplan-uat

# Production
terraform plan -var-file="envs/prod.tfvars" -out=tfplan-prod
```

### Apply Configuration

```bash
# Development
terraform apply tfplan-dev

# UAT
terraform apply tfplan-uat

# Production
terraform apply tfplan-prod
```

### Destroy Resources

```bash
terraform destroy -var-file="envs/dev.tfvars"
```

## Resources Created

### AWS IAM
- **IAM Policy**: AWSLoadBalancerControllerIAMPolicy
- **IAM Role**: alb-controller-role with IRSA trust relationship
- **Role Attachment**: Policy attached to role

### Kubernetes
- **Namespace**: kube-system (or specified)
- **Service Account**: aws-load-balancer-controller with IRSA annotation

### Helm
- **Chart**: aws-load-balancer-controller
- **Repository**: https://aws.github.io/eks-charts
- **Default Replicas**: 2
- **Node Selector**: workload=system

## Helm Release Details

```yaml
Chart: aws-load-balancer-controller
Namespace: kube-system
Values:
  - clusterName: flaskapp-eks-cluster
  - region: ap-south-1
  - vpcId: 10.0.0.0/16
  - serviceAccount.create: false
  - replicaCount: 2
  - Resource limits for controlled deployment
```

## Outputs

- `alb_controller_role_arn` - ARN of ALB controller IAM role
- `alb_controller_role_name` - Name of ALB controller IAM role
- `alb_controller_policy_arn` - ARN of ALB controller IAM policy
- `alb_helm_release_status` - Status of Helm release
- `alb_helm_release_version` - Version of deployed Helm chart
- `alb_service_account_name` - Kubernetes service account name

## Separation from Main Infrastructure

The ALB controller configuration was **removed from** the main EKS infrastructure pipeline:

### Commented Out Locations

1. **`/Iac/Terraform/modules/aws_iam_roles/main.tf`**
   - aws_iam_policy "alb_controller"
   - aws_iam_role "alb_controller"
   - aws_iam_role_policy_attachment "alb_attach"

2. **`/Iac/Terraform/modules/aws_iam_roles/out.tf`**
   - output "alb_controller_role_arn"

3. **`/Iac/Terraform/envs/dev/main.tf`**
   - module "aws_alb_cont"
   - resource "kubernetes_service_account_v1" "alb_controller"

## Workflow Integration

For GitHub Actions or CI/CD pipelines, create a separate workflow file that:

1. Runs independently from the main infrastructure pipeline
2. Can be triggered on schedule or manual dispatch
3. Uses the separate S3 backend for state
4. Publishes outputs to another stack or repository

## Troubleshooting

### ALB Controller Pod Not Starting

```bash
# Check pod status
kubectl get pods -n kube-system | grep aws-load-balancer-controller

# Check logs
kubectl logs -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller -f

# Check service account annotation
kubectl describe sa aws-load-balancer-controller -n kube-system
```

### IRSA Not Working

```bash
# Verify OIDC provider
aws iam list-open-id-connect-providers

# Check role trust relationship
aws iam get-role --role-name alb-controller-role-dev
```

### Helm Release Issues

```bash
# Get Helm release status
helm status aws-load-balancer-controller -n kube-system

# Get release history
helm history aws-load-balancer-controller -n kube-system
```

## Security Best Practices

1. ✅ **IRSA Enabled** - IAM credentials scoped to service account
2. ✅ **Least Privilege** - Specific IAM policy for ALB operations
3. ✅ **State Encryption** - S3 backend with encryption enabled
4. ✅ **State Locking** - DynamoDB table prevents concurrent modifications
5. ✅ **Separate State** - ALB state isolated from infrastructure state

## Related Documentation

- [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/)
- [EKS IRSA](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html)
- [Terraform Helm Provider](https://registry.terraform.io/providers/hashicorp/helm/latest/docs)
