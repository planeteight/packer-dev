# Demonstrates parameterizing a build with variables, including a
# required variable (no default) and a sensitive one.

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

# Required: must be passed via -var, -var-file, or an auto.pkrvars.hcl file.
variable "environment" {
  type = string
}

# Example of a sensitive variable pulled from the environment.
# Not used by the AWS builder itself here, just demonstrating the pattern
# for a provisioner that might need e.g. an API token.
variable "app_token" {
  type      = string
  sensitive = true
  default   = env("APP_TOKEN")
}

locals {
  ami_name = "packer-learning-${var.environment}-{{timestamp}}"
}

source "amazon-ebs" "ubuntu" {
  ami_name      = local.ami_name
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
    owners      = ["099720109477"]
  }

  tags = {
    Name        = local.ami_name
    Environment = var.environment
    BuiltBy     = "packer"
  }
}

build {
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "shell" {
    inline = ["echo Building for environment: ${var.environment}"]
  }
}
