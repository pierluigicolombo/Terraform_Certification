terraform {

  backend "remote" {
    hostname = "app.terraform.io"
    organization = "PierluigiOrganization"

    workspaces {
      name = "Terraform-certification-ws"
    }
  }
  

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.58.0"
    }
  }

  required_version = ">= 1.2.0"
}

locals{
  project_name = "Pierluigi"
}