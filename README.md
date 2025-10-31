# Terraform code

## Terraform state storage 
Terraform requires and S3 bucket to mange, store and lock multiple state files.
- [terraform/aws/state/dev/](terraform/aws/state/dev/)

Since this is the very first part of the terraform setup I stored the state in git as well and create a [state module](terraform/modules/state) for it.

## Main Terraform
For the resources needed for this project can be found under:
- [terraform/aws/environments/dev](terraform/aws/environments/dev)

Module used for the required resources:
- [S3 bucket](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket)
- Service account / user
  - [iam-oidc-provider](https://github.com/terraform-aws-modules/terraform-aws-iam/tree/master/modules/iam-oidc-provider) OIDC provider for github action 
  - [iam-role](https://github.com/terraform-aws-modules/terraform-aws-iam/tree/master/modules/iam-role) IAM role for what GitHub action can use
  - [iam-user](https://github.com/terraform-aws-modules/terraform-aws-iam/tree/master/modules/iam-user) credentials for auxiliary service (IRSA would be ab etter approach here)
- (for AWS Parameter Store I just used a simple resource and set some test paramters)

## Variables
- `name` for application name
- `environment`, `aws_region` for re-usability and tagging
- `parameters` test parameters

# GitHub Actions workflow:

## [Terraform GitHub Action](.github/workflows/main.yaml)
- Check out source code from GitHub
- Configure AWS Credentials (using GitHub OIDC)
- Validate Terraform code
- Scan Terraform security with Trivy

## Applications GitHub Action ([main](https://github.com/2solt/main-kxc/blob/main/.github/workflows/main.yaml), [aux](https://github.com/2solt/aux-kxc/blob/main/.github/workflows/main.yaml))
- Check out source code from GitHub
- If helm chart changed
  - Examine a chart for possible issues (Lint)
  - Make sure helm chart template renders correctly
- Check possible issue with the code with golangci-lint
- Scan Helm and code security with Trivy
- Building the docker image
- Configure DockerHub credentials
- Push image tagged with the commit hash
- Update the image tag in the Environment specific helm value file. (this will trigger a deployment)

# Deployment instructions

## [Installing Kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)
```
brew install kind
kind create cluster
```

## [Install ArgoCD](https://argo-cd.readthedocs.io/en/stable/try_argo_cd_locally/#try-argo-cd-locally)
Install ArgoCD on the Cluster:
```
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```
Expose ArgoCD API Serve:
```
kubectl port-forward svc/argocd-server -n argocd 8080:443
```
Get the password for the `admin` user
```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
```
Log in with via http://localhost:8080

## Install the Argo ApplicationsSet

Since we don't have IRSA setup for Kind adding credentials as secret
```
kubectl create namespace dev-aux
kubectl -n dev-aux create secret generic aws-secret --from-literal=key=${AWS_SECRET_ACCESS_KEY}
kubectl -n dev-aux create secret generic aws-id --from-literal=key=${AWS_ACCESS_KEY_ID}
```

Install the applications
```
kubectl apply -f argocd/applicationSet.yaml -n argocd
```

You can verify that the deployments were successful via ArgoCD UI: https://127.0.0.1:8090/applications

Applications status should be green `Healthy` and `Synced`

# API testing guide:

## Port forward main service from Kind

```
kubectl port-forward svc/dev-main -n dev-main 8080:8080
```
(There is a docker-compose file which can be used for development and testing)

## Testing with curl against the main application

List all S3 buckets in the AWS account:
```sh
curl -sX GET "127.0.0.1:8080/buckets" | jq .
```
```json
{
  "version": "50d3f027b0305870577be4c0ce93515076bc8527",
  "aux_version": "02240ef42de5a2cc068da28c08a562eb9ee6ee2c",
  "data": [
    "aux-kxc",
    "terraform-state-kxc"
  ]
}
```

List all parameters stored in AWS Parameter Store:
```sh
curl -sX GET "127.0.0.1:8080/parameters" | jq .
```
```json
{
  "version": "50d3f027b0305870577be4c0ce93515076bc8527",
  "aux_version": "02240ef42de5a2cc068da28c08a562eb9ee6ee2c",
  "data": [
    "a",
    "b",
    "c"
  ]
}
```

Retrieve the value of a specific parameter from AWS Parameter Store:
```sh
curl -sX GET "127.0.0.1:8080/parameters/a" | jq .
```
```json
{
  "version": "50d3f027b0305870577be4c0ce93515076bc8527",
  "aux_version": "02240ef42de5a2cc068da28c08a562eb9ee6ee2c",
  "data": "1"
}
```

## Testing with curl against the main application

List all S3 buckets in the AWS account:
```sh
curl -sX GET "127.0.0.1:8081/buckets" | jq .
```
```json
{
  "version": "02240ef42de5a2cc068da28c08a562eb9ee6ee2c",
  "data": [
    "aux-kxc",
    "terraform-state-kxc"
  ]
}
```

List all parameters stored in AWS Parameter Store:
```sh
curl -sX GET "127.0.0.1:8081/parameters" | jq .
```
```json
{
  "version": "02240ef42de5a2cc068da28c08a562eb9ee6ee2c",
  "data": [
    "a",
    "b",
    "c"
  ]
}
```

Retrieve the value of a specific parameter from AWS Parameter Store:
```sh
curl -sX GET "127.0.0.1:8081/parameters/a" | jq .
```
```json
{
  "version": "02240ef42de5a2cc068da28c08a562eb9ee6ee2c",
  "data": "1"
}
```

# Github repositories
  - https://github.com/2solt/kxc
  - https://github.com/2solt/main-kxc
  - https://github.com/2solt/aux-kxc
