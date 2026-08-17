# 05 — Provisioners

Provisioners run *inside* the temporary build instance, before it's saved as an AMI. Walkthrough for [`examples/02-with-provisioner`](../examples/02-with-provisioner).

## The `shell` provisioner

Most common starting point. Two ways to give it commands:

```hcl
provisioner "shell" {
  inline = [
    "sudo apt-get update",
    "sudo apt-get install -y nginx"
  ]
}
```

or point it at a script file:

```hcl
provisioner "shell" {
  script = "scripts/install-nginx.sh"
}
```

Scripts run as the `ssh_username` user — use `sudo` inside the script for privileged commands, since Packer doesn't run the whole script as root by default (unless you set `execute_command` to elevate).

## The `file` provisioner

Copies a local file/directory into the instance before other provisioners run:

```hcl
provisioner "file" {
  source      = "configs/app.conf"
  destination = "/tmp/app.conf"
}

provisioner "shell" {
  inline = ["sudo mv /tmp/app.conf /etc/app/app.conf"]
}
```

Note the two-step dance: `file` provisioner can't write directly to root-owned paths, so it's common to drop the file in `/tmp` then `sudo mv` it in a follow-up shell step.

## Provisioners run in order

Multiple provisioner blocks execute top-to-bottom. This matters when e.g. copying a file then referencing it:

```hcl
build {
  sources = ["source.amazon-ebs.example"]

  provisioner "file" {
    source      = "app/"
    destination = "/tmp/app"
  }

  provisioner "shell" {
    inline = ["sudo mv /tmp/app /opt/app", "sudo systemctl enable app"]
  }
}
```

## Other provisioners worth knowing

- `ansible` — run an Ansible playbook against the build instance
- `powershell` / `windows-restart` — for Windows AMI builds
- `breakpoint` — pauses the build so you can SSH in manually and debug (great for troubleshooting a failing provisioner)

## Things that tripped me up

- `apt-get` output can be very noisy; add `-y` and consider `DEBIAN_FRONTEND=noninteractive` to avoid a hung prompt.
- If a provisioner exits non-zero, the whole build fails and the temp instance is torn down — use `packer build -on-error=ask` while debugging to pause instead of immediately cleaning up.
