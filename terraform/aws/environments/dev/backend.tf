terraform {
  backend "s3" {
    bucket       = "terraform-state-kxc"
    key          = "aux/dev/main.tfstate"
    region       = "eu-west-1"
    use_lockfile = true
    encrypt      = true
  }
}
