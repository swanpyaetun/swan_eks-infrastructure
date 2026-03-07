terraform {
  backend "s3" {
    region       = "ap-southeast-1"
    bucket       = "swan-terraform-backend"
    key          = "swan_prerequisites/terraform.tfstate"
    use_lockfile = true # s3 state locking
  }
}