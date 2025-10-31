module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.8.2"

  bucket = "aux-kxc"
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"
}
