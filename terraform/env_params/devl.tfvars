#---------------------------------------------------------------------------------------------------------
# This is called the variable file from where we pass the variable values to the main.tf terraform file.
#---------------------------------------------------------------------------------------------------------
ami             = "ami-0cea098ed2ac54925"
EC2_Type   = "t2.medium"
EC2_efs_name = "MyProduct"   #efs file system name
EC2_user      = "ec2-user"  #connection user 
EC2_connectionType       = "ssh" #connection type
EC2_lb_targetgroupname        = "webserver-tg"
ec2_subnet_id =  "subnet-f8f129a3"
ec2_subnet_id1 = "subnet-86229fad"
lb_type = "application"
lb_action = "forward"
lb_protocol = "HTTP"
EC2_region = "us-west-2"