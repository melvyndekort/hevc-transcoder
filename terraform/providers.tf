terraform {
  cloud {
    organization = "melvyndekort"

    workspaces {
      name = "hevc-encoder"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.8.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}
