terraform {
  backend "s3" {
    bucket       = "swan-production-terraform-backend"
    key          = "swan_production/terraform.tfstate"
    region       = "ap-southeast-1"
    use_lockfile = true #s3 state locking
    encrypt      = true
  }
}