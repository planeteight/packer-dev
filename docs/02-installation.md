# 02 — Installation & AWS setup

## Installing Packer

**macOS (Homebrew):**
```bash
brew tap hashicorp/tap
brew install hashicorp/tap/packer
```

**Linux (apt):**
```bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install packer
```

**Windows (Chocolatey):**
```powershell
choco install packer
```

Verify:
```bash
packer version
```

## AWS credentials

Packer's `amazon-ebs` builder uses the standard AWS credential chain — it looks in this order:

1. Environment variables: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`
2. Shared credentials file (`~/.aws/credentials`), optionally with `AWS_PROFILE=myprofile`
3. IAM role attached to the instance/CI runner (best option in CI)

For local learning, the simplest path:
```bash
aws configure --profile packer-learning
export AWS_PROFILE=packer-learning
```

## Minimal IAM policy

Packer needs permission to launch instances, manage AMIs/snapshots, and manage temporary key pairs/security groups it creates for the build. A reasonable starting policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AttachVolume",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:CopyImage",
        "ec2:CreateImage",
        "ec2:CreateKeypair",
        "ec2:CreateSecurityGroup",
        "ec2:CreateSnapshot",
        "ec2:CreateTags",
        "ec2:CreateVolume",
        "ec2:DeleteKeyPair",
        "ec2:DeleteSecurityGroup",
        "ec2:DeleteSnapshot",
        "ec2:DeleteVolume",
        "ec2:DeregisterImage",
        "ec2:DescribeImageAttribute",
        "ec2:DescribeImages",
        "ec2:DescribeInstances",
        "ec2:DescribeInstanceStatus",
        "ec2:DescribeRegions",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSnapshots",
        "ec2:DescribeSubnets",
        "ec2:DescribeTags",
        "ec2:DescribeVolumes",
        "ec2:DetachVolume",
        "ec2:GetPasswordData",
        "ec2:ModifyImageAttribute",
        "ec2:ModifyInstanceAttribute",
        "ec2:ModifySnapshotAttribute",
        "ec2:RegisterImage",
        "ec2:RunInstances",
        "ec2:StopInstances",
        "ec2:TerminateInstances"
      ],
      "Resource": "*"
    }
  ]
}
```

Tighten with resource-level restrictions once you're past the learning phase.

## Things that tripped me up

- Forgetting to `export AWS_PROFILE` (or `AWS_DEFAULT_REGION`) in a new shell and getting a confusing "no valid credential sources" error.
- `packer init .` must be run once per template directory to download the required plugins (e.g. the `amazon` plugin) before `build` or `validate` will work.
