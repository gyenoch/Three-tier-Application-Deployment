terraform {
  backend "s3" {
    bucket = "3-tier-deployment-eks"
    key    = "eks/terraform.tfstate"
    region = "us-east-1"
  }
}