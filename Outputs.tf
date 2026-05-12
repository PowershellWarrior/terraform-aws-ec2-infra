##############################################################################
# outputs.tf
# WHY THIS FILE EXISTS:
#   Outputs print useful information to your terminal after terraform apply
#   completes. Without this file you would have to manually log into the
#   AWS console to find your EC2 public IP every single time.
##############################################################################

output "ec2_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.main.public_ip
}

output "ec2_instance_id" {
  description = "The unique instance ID assigned by AWS"
  value       = aws_instance.main.id
}

output "vpc_id" {
  description = "The ID of the custom VPC"
  value       = aws_vpc.main.id
}

output "ssh_connection_string" {
  description = "Ready-to-use SSH command to connect to your instance"
  value       = "ssh -i ~/.ssh/${var.key_pair_name}.pem ec2-user@${aws_instance.main.public_ip}"
}