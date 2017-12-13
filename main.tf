resource "random_string" "AdminPassword" {
  length  = 16
  special = false
}

provider "aws" {
  region = "eu-west-2"
}
