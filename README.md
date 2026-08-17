# Learning Packer (AWS AMIs)

My notes and working examples while learning [HashiCorp Packer](https://developer.hashicorp.com/packer), focused on building AWS AMIs.

## Roadmap

- [ ] 01 — [What is Packer?](docs/01-what-is-packer.md)
- [ ] 02 — [Installation & setup](docs/02-installation.md)
- [ ] 03 — [HCL2 syntax basics](docs/03-hcl2-basics.md)
- [ ] 04 — [Building your first AMI](docs/04-building-first-ami.md)
- [ ] 05 — [Provisioners](docs/05-provisioners.md)
- [ ] 06 — [Variables & secrets](docs/06-variables-and-secrets.md)
- [ ] 07 — [Best practices & CI/CD](docs/07-best-practices-and-cicd.md)

Check off each box as you work through it — that's your progress tracker.

## Examples

| Folder | What it shows |
|---|---|
| [`examples/01-minimal-ami`](examples/01-minimal-ami) | Smallest possible AWS AMI build, no provisioning |
| [`examples/02-with-provisioner`](examples/02-with-provisioner) | Adds a shell provisioner to install packages |
| [`examples/03-variables`](examples/03-variables) | Parameterizes the build with input variables |
| [`examples/04-multi-provisioner-full`](examples/04-multi-provisioner-full) | A more realistic build: variables + shell + file provisioner + validation |

## Prerequisites

- An AWS account with programmatic access (access key / secret key, or SSO profile)
- IAM permissions to launch EC2 instances, create AMIs, and manage snapshots (see [docs/02-installation.md](docs/02-installation.md) for a minimal policy)
- Packer installed locally (see install doc)

## Quick start

```bash
cd examples/01-minimal-ami
packer init .
packer fmt .
packer validate .
packer build .
```

## Notes format

Each file in `docs/` is written as personal study notes: a short explanation in my own words, then a "things that tripped me up" section. Feel free to fork and adapt.
