# 07 — Best practices & CI/CD

## Naming & tagging

Tag every AMI with build metadata so old/stale ones are easy to find and clean up later:

```hcl
tags = {
  Name        = "app-${var.environment}-{{timestamp}}"
  BuiltBy     = "packer"
  SourceRepo  = "packer-learning"
  GitCommit   = "${env("GITHUB_SHA")}"
}
```

## Keep base images patched

Don't pin to an old `source_ami` forever — use `most_recent = true` with a filter so each build starts from a current, patched base image, then let your provisioners layer app-specific config on top.

## Validate before you build

```bash
packer fmt -check .     # fails if formatting is off (good for CI)
packer validate .       # catches config errors without launching anything
```

Wire both into a pre-commit hook or CI job so bad templates never reach a real build.

## A simple GitHub Actions workflow

```yaml
name: packer-validate
on:
  pull_request:
    paths:
      - "examples/**"

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: hashicorp/setup-packer@main
      - run: |
          cd examples/04-multi-provisioner-full
          packer init .
          packer fmt -check .
          packer validate .
```

Building real AMIs in CI needs AWS credentials (an OIDC role is the modern, keyless approach) — start with validate-only in CI, add a manual-trigger build job once you're comfortable.

## AMI cleanup / lifecycle

Packer doesn't delete old AMIs for you. Options as you grow:
- A scheduled Lambda or script that deregisters AMIs older than N days
- AWS Backup / Data Lifecycle Manager policies on the snapshots
- Just doing it manually while learning — `aws ec2 describe-images --owners self`

## Things that tripped me up

- Forgetting that **snapshots** cost money independently of the AMI — deregistering an AMI does not delete its backing snapshot; that's a separate `delete-snapshot` call.
- Packer plugin versions matter: pin `required_plugins` version constraints so a `packer init` months later doesn't silently pull a breaking plugin update.
