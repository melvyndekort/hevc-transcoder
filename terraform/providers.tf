terraform {
  required_version = "~> 1.5.0"

  backend "s3" {
    bucket = "mdekort.tfstate"
    key    = "hevc-transcoder.tfstate"
    region = "eu-west-1"
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
