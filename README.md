# actions-terraform-aws

This repository contains code for a demo of using GitHub Actions to deploy AWS resources via Terraform.

## Github Actions prerequisites

In order to deploy Terraform resources using GitHub actions, the following prerequisites should be performed.

### 1 - Terraform remote backend

In order to use Terraform in Github Actions, you need to create an [S3 Terraform backend](https://developer.hashicorp.com/terraform/language/settings/backends/s3)
where the state will be stored.

[terraform_s3_backend_cfn.yaml](./prerequisites/terraform_s3_backend_cfn.yaml) contains an exemple CloudFormation template to help you deploy required resources for Terraform S3 Backend.

You can deploy it as follows (you can change the exported variables to suite your use case):

```
export STACK_NAME="terraform-s3-backend-resources"
export REGION="us-east-1"
export BUCKET_NAME="terraform-s3-backend-72189776"
export DYNAMODB_TABLE_NAME="terraform-dynamodb-lock-table"
aws cloudformation deploy --region $REGION  \
                --stack-name $STACK_NAME \
                --template-file terraform_s3_backend_cfn.yaml \
                --capabilities "CAPABILITY_NAMED_IAM" \
                --parameter-overrides BucketName="$BUCKET_NAME" \
                                        DynamoDbTableName="$DYNAMODB_TABLE_NAME"
```

### 2 - GitHub Actions OIDC IAM Provider and IAM Role

In order to give Github Actions workflows permission to act on AWS resources, you need to create some resources in your AWS account. For more information, please refer
to Github documentation [Configuring OpenID Connect in Amazon Web Services](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services)

[github_actions_cfn.yaml](./prerequisites/github_actions_cfn.yaml) contains an example CloudFormation template that creates an OIDC IAM Provider and an IAM Role that can be assumed by Github Actions.

You can deploy it as follows (you can change the exported variables to suite your use case):

```
export STACK_NAME="github-actions-resources"
export REGION="us-east-1"
export TERRAFORM_S3_BACKEND_POLICY_ARN="$(aws cloudformation describe-stacks --region "us-east-1" --stack-name terraform-s3-backend-resources --query "Stacks[0].Outputs[?OutputKey=='TerraformS3BackendIamPolicyArn'].OutputValue" --output text)"
export GITHUB_ORGANIZATION_NAME="younux"
export GITHUB_REPO_NAME="actions-terraform-aws"
export IAM_ROLE_NAME="github-actions-role"
aws cloudformation deploy --region $REGION \
                --stack-name $STACK_NAME \
                --template-file "github_actions_cfn.yaml" \
                --capabilities "CAPABILITY_NAMED_IAM" \
                --parameter-overrides GithubOrganizationName="$GITHUB_ORGANIZATION_NAME" \
                                        GithubRepoName="$GITHUB_REPO_NAME" \
                                        IamRoleName="$IAM_ROLE_NAME" \
                                        TerraformS3BackendPolicyArn="$TERRAFORM_S3_BACKEND_POLICY_ARN"
```
