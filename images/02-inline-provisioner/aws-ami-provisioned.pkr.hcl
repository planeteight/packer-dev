# Same base as example 01, but installs nginx and injects a project-local
# site config from files/ to demonstrate the file provisioner pattern.

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

variable "vpc_id" {
  type    = string
  default = "vpc-0f9c1e3e"
}

variable "subnet_id" {
  type    = string
  default = "subnet-0f9c1e3e"
}
source "amazon-ebs" "ubuntu" {
  ami_name      = "packer-learning-nginx-{{timestamp}}"
  instance_type = var.instance_type
  region        = var.region
  ssh_username  = "ubuntu"
  subnet_id     = var.subnet_id
  vpc_id        = var.vpc_id

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
    Name    = "packer-learning-nginx"
    BuiltBy = "packer"
  }
}

build {
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "shell" {
    env = {
      DEBIAN_FRONTEND = "noninteractive"
    }
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx",
      "sudo systemctl enable nginx",
      "sudo mkdir -p /var/www/html",
    ]
  }

  provisioner "file" {
    source      = "files/nginx-config"
    destination = "/tmp/nginx-config"
  }

  provisioner "file" {
    source      = "files/website"
    destination = "/tmp/website"
  }

  provisioner "shell" {
    inline = [
      "sudo mv /tmp/nginx-config/default-site.conf /etc/nginx/sites-available/default",
      "sudo cp -r /tmp/website/. /var/www/html/",
      "sudo chown -R www-data:www-data /var/www/html",
      "sudo nginx -t",
      "sudo systemctl restart nginx",
      "echo 'Build finished at' $(date)",
    ]
  }
}
