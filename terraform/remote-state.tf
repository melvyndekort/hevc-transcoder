data "terraform_remote_state" "tf_aws" {
  backend = "s3"

  config = {
    bucket = "mdekort.tfstate"
    key    = "tf-aws.tfstate"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "cloudsetup" {
  backend = "s3"

  config = {
    bucket = "mdekort.tfstate"
    key    = "cloudsetup.tfstate"
    region = "eu-west-1"
  }
}
