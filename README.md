# terraform-aws-ec2-infra

![Terraform](https://img.shields.io/badge/Terraform-1.x-7B42BC?logo=terraform)
![AWS](https://img.shields.io/badge/AWS-Free%20Tier-FF9900?logo=amazonaws)
![License](https://img.shields.io/badge/License-MIT-blue)
![Status](https://img.shields.io/badge/Status-Active-success)

> Provisions a secure AWS EC2 instance inside a custom VPC using Terraform — 
> fully parameterized, free-tier safe, and documented as Infrastructure as Code.

## Overview
This project provisions a complete AWS environment using Terraform — 
including a custom VPC, subnet, Internet Gateway, security group, 
and EC2 instance — fully defined as Infrastructure as Code.

## Skills Demonstrated
1. Infrastructure as Code (IaC) — using Terraform to define,
   deploy, and destroy cloud infrastructure through code
2. AWS & Cloud Fundamentals — VPC networking, EC2 compute,
   and core AWS resource relationships
3. Security-Based Design — least privilege IAM, IP-restricted
   SSH access, and secrets management best practices

## Main Objective
Successfully provision a fully functional AWS server environment
through Terraform code — complete with an isolated network,
firewall rules, and SSH access — and fully deprovision all
infrastructure with a single command.

## Architecture
│
│ Port 22 — Your IP only (/32 CIDR)
▼
Internet Gateway (aws_internet_gateway)
│
▼
VPC (aws_vpc) — 10.0.0.0/16
│
▼
Public Subnet (aws_subnet) — 10.0.1.0/24
│
▼
Route Table (aws_route_table) — 0.0.0.0/0 → Internet Gateway
│
▼
Security Group (aws_security_group) — Port 22 → Your IP only
│
▼
EC2 Instance (aws_instance) — t2.micro | Amazon Linux 2

### Resource Summary

| Resource                      | Name                                     | Purpose                     |
|-------------------------------|------------------------------------------|-----------------------------|
| `aws_vpc`                     | `terraform-aws-ec2-infra-vpc`            | Isolated private network    |
| `aws_internet_gateway`        | `terraform-aws-ec2-infra-igw`            | Connects VPC to internet    |
| `aws_subnet`                  | `terraform-aws-ec2-infra-public-subnet`  | Public subnet for EC2       |
| `aws_route_table`             | `terraform-aws-ec2-infra-public-rt`      | Routes traffic to gateway   |
| `aws_route_table_association` | N/A                                      | Links route table to subnet |
| `aws_security_group`          | `terraform-aws-ec2-infra-sg`             | Firewall — SSH restricted   |
| `aws_instance`                | `terraform-aws-ec2-infra-ec2`            | The live EC2 server         |

## Prerequisites

Before using this project, ensure the following are installed and configured:

| Tool | Version | Purpose |
|---|---|---|
| [Terraform](https://developer.hashicorp.com/terraform/install) | >= 1.6.0 | Infrastructure provisioning |
| [AWS CLI](https://aws.amazon.com/cli/) | >= 2.0 | AWS authentication |
| [Git](https://git-scm.com/) | Any | Clone this repository |

**AWS Requirements:**
- An AWS Free Tier account
- An IAM user with programmatic access — never use your root account
- AWS CLI configured via `aws configure`
- An existing EC2 Key Pair created in your target region

> ⚠️ **Security Warning:** Never configure the AWS CLI with your root account
> credentials. Always create an IAM user with least-privilege permissions
> and use those credentials.

## Usage

This project is designed to be run locally against your AWS account.
All configurable values live in `terraform.tfvars` — you never need
to edit `main.tf` directly. Follow the sub-sections below in order.

### Installation

1. Clone the repository:
```bash
   git clone https://github.com/YOUR_USERNAME/terraform-aws-ec2-infra.git
   cd terraform-aws-ec2-infra
```

2. Copy the example variables file and fill in your values:
```bash
   cp terraform.tfvars.example terraform.tfvars
```

3. Open `terraform.tfvars` and set your values:
```hcl
   aws_region    = "us-east-1"
   instance_type = "t2.micro"
   your_ip_cidr  = "YOUR.IP.HERE/32"
   key_pair_name = "your-key-pair-name"
```

4. Find your public IP to fill in `your_ip_cidr`:
```bash
   # Mac/Linux
   curl https://api.ipify.org

   # Windows PowerShell
   (Invoke-WebRequest -Uri "https://api.ipify.org").Content
```

> ⚠️ **Never commit `terraform.tfvars` to GitHub.** It is listed in
> `.gitignore` by default. It may contain your IP address and key
> pair name which should remain local only.

### Running Terraform

**Step 1 — Initialize** (downloads the AWS provider plugin):
```bash
terraform init
```

**Step 2 — Validate** (catches syntax errors before touching AWS):
```bash
terraform validate
```

**Step 3 — Plan** (previews every change — always review before applying):
```bash
terraform plan
```

> 📋 Read the plan output carefully. It tells you exactly what Terraform
> will create, modify, or destroy. Never skip this step.

**Step 4 — Apply** (provisions all 7 AWS resources):
```bash
terraform apply
```
Type `yes` when prompted. Terraform will output your EC2 public IP
and a ready-to-use SSH connection string when complete.

**Step 5 — Connect via SSH** (verify your instance is live):
```bash
# Mac/Linux
ssh -i ~/.ssh/your-key.pem ec2-user@YOUR_PUBLIC_IP

# Windows PowerShell
ssh -i "C:\Users\YourName\.ssh\your-key.pem" ec2-user@YOUR_PUBLIC_IP
```

**Step 6 — Destroy** (tears everything down, stops all AWS charges):
```bash
terraform destroy
```

> ⚠️ **Always run destroy when finished.** Even free-tier resources
> can accumulate charges if left running beyond the monthly limit.

## Security Design Decisions

Every security choice in this project was intentional. The following
documents what was implemented and why — demonstrating security-first
IaC thinking.

- **Custom VPC over default VPC** — The AWS default VPC is pre-configured
  for convenience, not security. A custom VPC gives full control over
  network boundaries and is the standard in professional environments.

- **SSH restricted to a single IP** — Port 22 open to `0.0.0.0/0` is one
  of the most common AWS misconfigurations found in security audits. This
  project restricts SSH access to your machine only via a `/32` CIDR block.

- **No credentials in code** — AWS credentials are never hardcoded anywhere
  in this project. Terraform reads them automatically from the AWS CLI
  credential chain at `~/.aws/credentials`.

- **terraform.tfvars in .gitignore** — Variable files containing
  environment-specific values are excluded from version control to
  prevent accidental exposure of configuration data.

- **Least privilege IAM** — The AWS IAM user configured for this project
  is granted only the minimum permissions required — `AmazonEC2FullAccess`
  and `AmazonVPCFullAccess`. Root account credentials are never used.

- **Dynamic AMI lookup** — Instead of hardcoding an AMI ID that becomes
  outdated, this project uses a data source to always fetch the latest
  official Amazon Linux 2 AMI for the target region automatically.

- **delete_on_termination enabled** — The EC2 root volume is configured
  to delete automatically when the instance is terminated, preventing
  orphaned EBS volumes and unexpected storage charges.
