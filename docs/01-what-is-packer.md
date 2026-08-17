# 01 — What is Packer?

## The idea

Packer is a tool from HashiCorp that builds **machine images** from a single source template. Instead of manually launching a server, installing software, and saving an image, you describe the desired end state in a config file and Packer automates the process:

1. Launch a temporary "build" instance from a base image
2. Run provisioners against it (shell scripts, Ansible, file copies, etc.)
3. Stop the instance and save it as a new image (an AMI, for AWS)
4. Terminate the temporary instance

The result is a **golden image** — a snapshot with your OS, packages, config, and users already baked in, ready to launch instantly.

## Why not just use a startup script / user-data?

You can install things at boot time with `user_data`, but that means:
- Every instance launch pays the install/config cost (slower boot)
- You depend on package mirrors / the internet being up at boot time
- Config drift is possible if scripts behave differently over time

Baking an AMI ahead of time means instances boot fast and consistently, and you can version and test the image itself, separate from the app deploy.

## Where Packer fits with other HashiCorp tools

- **Packer** — builds the image (what the machine *is*)
- **Terraform** — provisions infrastructure and launches instances *from* that image (what exists and how it's wired together)

A common pattern: Packer builds an AMI → Terraform's `aws_instance` or an Auto Scaling Group launch template references that AMI ID.

## Key vocabulary

| Term | Meaning |
|---|---|
| **Template** | The `.pkr.hcl` file(s) describing the build |
| **Builder** | Plugin that knows how to talk to a platform, e.g. `amazon-ebs` for AWS |
| **Provisioner** | Something that customizes the instance before the image is saved (shell, ansible, file, etc.) |
| **Source** | A configured instance of a builder (in HCL2, `source "amazon-ebs" "example" { ... }`) |
| **Build block** | Ties one or more sources to a list of provisioners |
| **Artifact** | The output of a build — for AWS, this is an AMI ID |

## Things that tripped me up

- Packer doesn't manage the *lifecycle* of the AMI after it's built (deleting old ones, tagging for cleanup) — that's on you or a separate tool.
- The build instance is temporary and billed for the (usually short) time it's running — it's not the same as your production instances.
