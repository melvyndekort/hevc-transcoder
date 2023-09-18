data "terraform_remote_state" "cloudsetup" {
  backend = "remote"

  config = {
    organization = "melvyndekort"
    workspaces = {
      name = "cloudsetup"
    }
  }
}
