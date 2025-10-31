module "iam_oidc_provider" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-oidc-provider"
  version = "6.2.2"

  url = "https://token.actions.githubusercontent.com"
}

module "github_oidc_iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role"
  version = "6.2.2"

  name                   = var.name
  enable_github_oidc     = true
  oidc_wildcard_subjects = ["2solt/kxc:*"]

  policies = {
    S3ReadOnly  = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
    SSMReadOnly = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
  }
}
