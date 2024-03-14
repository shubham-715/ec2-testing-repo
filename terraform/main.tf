#------------------------------------------------------------------------------------------------------
# Data Sources: The data sources that are used to fetch already existing resources in AWS.
#------------------------------------------------------------------------------------------------------
# Data source to get the access to the effective Account ID, User ID, and ARN in which Terraform is authorized.


# Generate new private key 
resource "tls_private_key" "my_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Generate a key-pair with above key
resource "aws_key_pair" "deployer" {
  key_name   = var.EC2_instance_name
  public_key = tls_private_key.my_key.public_key_openssh
}

# Saving Key Pair for ssh login for Client if needed
resource "null_resource" "save_key_pair" {
  provisioner "local-exec" {
    command = "echo  ${tls_private_key.my_key.private_key_pem} > mykey.pem"
  }
}


# Creating a new security group for EC2 instance with ssh and http inbound rules
resource "aws_security_group" "ec2_security_group" {
  name        = var.EC2_instance_name
  description = "Allow SSH and HTTP"
  vpc_id      = var.ec2_vpc_id

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "EFS mount target"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# EC2 instance 
resource "aws_instance" "web" {
  ami             = var.ami
  instance_type   = var.EC2_Type
  key_name        = aws_key_pair.deployer.key_name
  security_groups = [aws_security_group.ec2_security_group.name]
  tags = {
    Name = var.EC2_instance_name
  }

  provisioner "local-exec" {
    command = "echo ${aws_instance.web.public_ip} > publicIP.txt"
  }
}

# Creating EFS file system
resource "aws_efs_file_system" "efs" {
  creation_token = var.EC2_instance_name

  tags = {
    Name = var.EC2_efs_name
  }
}

resource "aws_efs_mount_target" "mount" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = aws_instance.web.subnet_id
  security_groups = [aws_security_group.ec2_security_group.id]

}

# Load balancer for the AWS instance
resource "aws_lb_target_group" "test" {
  depends_on = [
    aws_instance.web
  ]
  name        = var.EC2_instance_name
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.ec2_vpc_id
  target_type = "instance"
}

resource "aws_lb_target_group_attachment" "web1" {
  depends_on = [
    aws_lb_target_group.test
  ]
  target_group_arn = aws_lb_target_group.test.arn
  target_id        = aws_instance.web.id
  port             = 80
}


resource "aws_lb" "test" {
  depends_on = [
    aws_lb_target_group.test
  ]
  name               = var.EC2_instance_name
  internal           = false
  load_balancer_type = var.lb_type
  security_groups    = [aws_security_group.ec2_security_group.id]
  subnets            = [var.ec2_subnet_id, var.ec2_subnet_id1]
}

resource "aws_lb_listener" "front_end" {
  depends_on = [
    aws_lb.test
  ]
  load_balancer_arn = aws_lb.test.arn
  port              = "80"
  protocol          = var.lb_protocol

  default_action {
    type             = var.lb_action
    target_group_arn = aws_lb_target_group.test.arn
  }
}