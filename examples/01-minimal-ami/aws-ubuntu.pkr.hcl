# Minimal Packer template: builds an AWS AMI from the latest Ubuntu 22.04,
# with no provisioning. Good for confirming your AWS credentials/region/
# networking are set up correctly before adding any complexity.

packer {
  required_plugins {
    amazon = {
      version = ">= 1.3.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "packer-learning-minimal-{{timestamp}}"
  instance_type = var.instance_type
  region        = var.region
  ssh_username  = "ubuntu"

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"] # Canonical
  }

  tags = {
    Name    = "packer-learning-minimal"
    BuiltBy = "packer"
  }
}

build {
  sources = ["source.amazon-ebs.ubuntu"]
}
