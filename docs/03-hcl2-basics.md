# 03 — HCL2 syntax basics

Modern Packer templates use HCL2 (the same language family as Terraform), file extension `.pkr.hcl`. The old JSON template format still works but HCL2 is the recommended path for new projects.

## The four block types you'll use constantly

```hcl
packer {
  required_plugins {
    amazon = {
      version = ">= 1.3.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

source "amazon-ebs" "example" {
  ami_name      = "learning-packer-{{timestamp}}"
  instance_type = var.instance_type
  region        = "us-east-1"
  # ... more config
}

build {
  sources = ["source.amazon-ebs.example"]

  provisioner "shell" {
    inline = ["echo Hello from Packer"]
  }
}
```

- **`packer` block** — declares required plugin versions. Run `packer init .` after editing this to install/update plugins.
- **`variable` blocks** — inputs to the template, similar to Terraform variables.
- **`source` blocks** — a configured builder instance. You reference it later as `source.<type>.<name>`.
- **`build` block** — glues one or more sources to a provisioner list.

## Useful commands

```bash
packer init .        # download/verify required plugins
packer fmt .          # auto-format templates
packer validate .     # check syntax + config without building
packer build .        # run the build
packer build -var 'instance_type=t3.small' .   # override a variable
packer console        # interactive HCL2 expression evaluator (like `terraform console`)
```

## Built-in template functions worth knowing early

- `timestamp()` — current UTC time, handy for unique AMI names
- `uuidv4()` — random UUID, useful for unique resource names
- `env("VAR_NAME")` — read an environment variable
- `templatefile("path", {...})` — render a file with variables interpolated

## Things that tripped me up

- HCL2 variables are **not** automatically pulled from environment variables the way Terraform's `TF_VAR_` prefix works — you either pass `-var`, use a `.pkrvars.hcl` file, or explicitly read `env(...)` inside the template.
- AMI names must be unique per region/account — forgetting `{{timestamp}}` or similar in `ami_name` causes a build failure on the second run.
