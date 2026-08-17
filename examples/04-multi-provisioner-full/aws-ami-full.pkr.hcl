# A more realistic build: variables, a file provisioner, a shell
# script provisioner, and tagging with build metadata. This is the
# template to copy as a starting point for a real project.

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

variable "environment" {
  type    = string
  default = "dev"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
  ami_name  = "packer-learning-full-${var.environment}-${local.timestamp}"
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
    SourceRepo  = "packer-learning"
  }
}

build {
  sources = ["source.amazon-ebs.ubuntu"]

  # Copy a config file up to a writable temp location first...
  provisioner "file" {
    source      = "files/app.conf"
    destination = "/tmp/app.conf"
  }

  # ...then move it into place with sudo and run the setup script.
  provisioner "shell" {
    env = {
      DEBIAN_FRONTEND = "noninteractive"
    }
    inline = [
      "sudo mkdir -p /etc/demo-app",
      "sudo mv /tmp/app.conf /etc/demo-app/app.conf",
    ]
  }

  provisioner "shell" {
    script = "scripts/setup.sh"
  }

  provisioner "shell" {
    inline = ["echo 'AMI build complete for environment: ${var.environment}'"]
  }
}
