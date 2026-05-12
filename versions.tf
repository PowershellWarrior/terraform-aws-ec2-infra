##############################################################################
# versions.tf
# WHY THIS FILE EXISTS:
#   Pinning provider versions is a professional non-negotiable. Without this,
#   terraform init pulls the latest provider which can silently break
#   your infrastructure when AWS releases breaking changes.
##############################################################################

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
