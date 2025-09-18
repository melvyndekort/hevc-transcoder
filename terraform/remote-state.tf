data "terraform_remote_state" "tf_aws" {
  backend = "s3"

  config = {
    bucket = "mdekort.tfstate"
    key    = "tf-aws.tfstate"
    region = "eu-west-1"
  }
}
