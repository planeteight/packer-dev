# 04 — Building your first AMI

Walkthrough for [`examples/01-minimal-ami`](../examples/01-minimal-ami).

## What the `amazon-ebs` source needs, minimum

- `region` — where to build (and where the AMI lands)
- `instance_type` — size of the temporary build instance
- `source_ami_filter` (or a hardcoded `source_ami`) — the base image to start from
- `ssh_username` — the login user Packer uses to connect and provision
- `ami_name` — name for the resulting AMI (must be unique)

## Finding a base AMI with a filter

Rather than hardcoding an AMI ID (which differs per region and goes stale), use a filter to always grab the latest matching image:

```hcl
source_ami_filter {
  filters = {
    name                = "al2023-ami-*-x86_64"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["amazon"]
}
```

## Running the build

```bash
cd examples/01-minimal-ami
packer init .
packer validate .
packer build .
```

Packer will:
1. Launch a temp instance from the filtered source AMI
2. SSH in (using a temporary keypair + security group it creates)
3. (no provisioners in this minimal example)
4. Stop the instance, create an AMI, terminate the instance
5. Print the new AMI ID at the end — save this, you'll use it in Terraform or the console

## Cleaning up

Packer deletes its temporary security group and key pair automatically. It does **not** delete the AMI or its backing snapshot — those persist (and cost a small amount for storage) until you deregister them:

```bash
aws ec2 deregister-image --image-id ami-xxxxxxxx
aws ec2 delete-snapshot --snapshot-id snap-xxxxxxxx
```

## Things that tripped me up

- A build with **zero** provisioners is valid — it just snapshots the base image unchanged. Good for testing your source config before adding complexity.
- If the build hangs at "Waiting for SSH to become available," it's almost always a security group / subnet routing issue (no route to the internet or no port 22 access) rather than Packer itself.
