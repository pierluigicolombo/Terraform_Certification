terraform {
  cloud {
    organization = "PierluigiOrganization"

    workspaces {
      name = "provisioners"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.59.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}

data "template_file" "user_data"{
  template = file("./userdata.yaml")
}

resource "aws_instance" "app_server" {
  ami           = "ami-087c17d1fe0178315"
  instance_type = "t2.micro"

  key_name = aws_key_pair.deployer.key_name

  vpc_security_group_ids = [aws_security_group.sg_my_server.id]

  user_data = data.template_file.user_data.rendered

  tags = {
    Name = "MyServerTerraformProvisioners"
  }
}



resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCwWwVg+Hc1kPcbHMN+Jh9eABF7Mmm0ihQhk6MxZahvqzGWqMAFwNnRr1s4PekajBr6G3wGZUK6dMwEoOJdCOoeqysVDAk1MyvbV41WV0/PTxJR9lrl6ofFFhFnNVyjnpc9gX7P/I2rvchwS0PTgDiwuqu0VN+CerXdBAYZX45vnUoZnfsRTLdW2zpuW9E8RKrmOCVtDwx+aUPmOihYJMFFFVIFCq+BB75GlYMKqSiH6BU4Ums52v693D97W5DWdRA09pWRfdJQ0DBM6j7Mc2NHEoKyMLnRBvtFh7+GeIznd3gCxfoy6E34NhLdnRcR61Y3FQ0DbCt9r5li6OgZYTJJ7v55wAhNgqjubDp0cxw0iMYjUw81kvb25XyNxAndE9w1sLSjNZxMgq1Pc3Lbo6r53exrXY0a3gFS59Y852JnK779rX7RdV0Z7+xEaoLMcE1LawH4+YobKFzBn9MSAPOzlIKMH0Xeblo7pgXxF4ldl6OFJ964uwY202MoHtJfD88= pierluigi@pierluigi-N552VW"
}


data "aws_vpc" "main"{
  id = "vpc-0f05c019020b7505a"
}


resource "aws_security_group" "sg_my_server" {
  name        = "sg_my_server"
  description = "My Server Security Group"
  vpc_id      = data.aws_vpc.main.id

  ingress = [
    {
      description      = "HTTP"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids = []       
      security_groups = []
      self = false
    },
    {
      description      = "SHH"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids = []       
      security_groups = []
      self = false
    }
  ]

  egress = [
    {
      description = "outgoing traffic"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids = []       
      security_groups = []
      self = false
    }
  ]

}


output "public_ip" {
  value       = aws_instance.app_server.public_ip
  sensitive   = false
  description = "public ip"
}
