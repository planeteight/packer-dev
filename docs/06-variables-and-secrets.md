# 06 — Variables & secrets

Walkthrough for [`examples/03-variables`](../examples/03-variables).

## Declaring variables

```hcl
variable "region" {
  type    = string
  default = "us-east-1"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "environment" {
  type = string
  # no default -> required at build time
}
```

Reference with `var.region` inside `source` or `build` blocks.

## Passing values in

Three ways, in increasing order of "good for real projects":

```bash
# 1. Command line flag
packer build -var 'environment=staging' .

# 2. A vars file
packer build -var-file="staging.pkrvars.hcl" .

# 3. Auto-loaded file (any *.auto.pkrvars.hcl in the directory loads automatically)
```

`staging.pkrvars.hcl`:
```hcl
environment   = "staging"
instance_type = "t3.small"
```

## Secrets

Never hardcode credentials in `.pkr.hcl` files. Options, roughly best-to-worst for a learning setup:

1. **AWS credential chain** (env vars, profile, or instance role) — the `amazon-ebs` builder picks these up automatically, no variable needed at all.
2. **Environment variable read via `env()`** for non-AWS secrets your provisioners need:
   ```hcl
   variable "api_token" {
     type      = string
     sensitive = true
     default   = env("MY_API_TOKEN")
   }
   ```
3. **`sensitive = true`** on the variable block — this redacts the value from Packer's console output and logs (doesn't encrypt it, just hides it from output).

## `.gitignore` this repo already has

```
*.pkrvars.hcl
!*.pkrvars.hcl.example
.packer.d/
packer_cache/
*.log
```

Commit a `*.pkrvars.hcl.example` template with dummy values so collaborators know what to fill in, but never the real file.

## Things that tripped me up

- `sensitive = true` hides the value in Packer's own output, but if a provisioner script echoes the variable to stdout, it'll still show up in build logs — the flag isn't a full secrets-management solution.
- Variables declared without a `default` are required; forgetting to pass one gives a reasonably clear error, but it's easy to forget in CI when a `.pkrvars.hcl` file isn't wired up.
