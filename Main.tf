##############################################################################
# main.tf
# WHY THIS FILE EXISTS:
#   This is the core infrastructure definition. Every AWS resource this
#   project creates lives here. It references variables from variables.tf
#   and never contains hardcoded values.
##############################################################################

##############################################################################
# VPC — Virtual Private Cloud
# WHY: Never use the AWS default VPC in a real project. The default VPC
#      is pre-configured for convenience, not security. A custom VPC gives
#      you full control over your network boundaries.
##############################################################################
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name    = "${var.project_name}-vpc"
    Project = var.project_name
  }
}

##############################################################################
# Internet Gateway
# WHY: Without this, your VPC is completely isolated from the internet.
#      The Internet Gateway is what allows your EC2 instance to be
#      reachable via SSH from your machine.
##############################################################################
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "${var.project_name}-igw"
    Project = var.project_name
  }
}

##############################################################################
# Public Subnet
# WHY: Subnets divide your VPC into smaller network segments. This public
#      subnet is where your EC2 instance lives. "Public" means resources
#      inside it can be assigned a public IP and reached from the internet
#      via the Internet Gateway.
##############################################################################
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"

  tags = {
    Name    = "${var.project_name}-public-subnet"
    Project = var.project_name
  }
}

##############################################################################
# Route Table
# WHY: A route table tells network traffic where to go. This route table
#      sends all outbound traffic (0.0.0.0/0) to the Internet Gateway —
#      making this subnet truly "public."
##############################################################################
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name    = "${var.project_name}-public-rt"
    Project = var.project_name
  }
}

##############################################################################
# Route Table Association
# WHY: Creating a route table does nothing until you associate it with a
#      subnet. This line connects the public route table to the public
#      subnet — completing the network path to the internet.
##############################################################################
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

##############################################################################
# Security Group
# WHY: A security group is your firewall. It controls what traffic can
#      reach your EC2 instance. This is the most security-critical
#      resource in this entire project.
##############################################################################
resource "aws_security_group" "ec2" {
  name        = "${var.project_name}-sg"
  description = "Security group for EC2 instance - SSH restricted to single IP"
  vpc_id      = aws_vpc.main.id

  # INBOUND — SSH access restricted to YOUR IP only
  # WHY: Opening port 22 to 0.0.0.0/0 is one of the most dangerous
  #      misconfigurations in AWS. Bots scan for open port 22 constantly.
  #      Restricting to /32 means only your machine can connect.
  ingress {
    description = "SSH from my IP only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.your_ip_cidr]
  }

  # OUTBOUND — Allow all outbound traffic
  # WHY: The EC2 instance needs to reach the internet to download
  #      updates and packages. Restricting outbound is an advanced
  #      topic beyond the scope of this project.
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-sg"
    Project = var.project_name
  }
}

##############################################################################
# Data Source — Latest Amazon Linux 2 AMI
# WHY: Instead of hardcoding an AMI ID (which changes per region and
#      becomes outdated), this data source dynamically fetches the latest
#      official Amazon Linux 2 AMI for your region automatically.
##############################################################################
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

##############################################################################
# EC2 Instance
# WHY: This is the actual server. Everything above this resource exists
#      to support this single instance — the VPC, subnet, Internet
#      Gateway, route table, and security group all feed into it.
##############################################################################
resource "aws_instance" "main" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.ec2.id]

  # Root volume configuration
  root_block_device {
    volume_size           = 8    # GB — minimum for Amazon Linux 2
    volume_type           = "gp2"
    delete_on_termination = true # Prevents orphaned volumes and charges
  }

  tags = {
    Name    = "${var.project_name}-ec2"
    Project = var.project_name
  }
}