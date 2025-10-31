module "iam_user" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "6.2.2"

  name                 = var.name
  create_access_key    = true
  create_login_profile = false
  policies = {
    S3ReadOnly  = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
    SSMReadOnly = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
  }
}
