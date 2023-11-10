terraform {
  required_version = "~> 1.5.0"

  cloud {
    organization = "melvyndekort"

    workspaces {
      name = "hevc-transcoder"
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
