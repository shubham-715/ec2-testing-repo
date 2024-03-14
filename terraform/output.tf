output "instance_ip_addr" {
  value       = aws_instance.web.private_ip
  description = "The private IP address of the main server instance."
}
output "instance_ami" {
  value       = aws_instance.web.ami
  description = "The ami of aws instance."
}

output "key_pair" {
  value       = aws_instance.web.key_name
  description = "The key_pair of aws instance."
}