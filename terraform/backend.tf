terraform {
  backend "s3" {
    bucket = "pe-port-terraform-backend"
    key    =  var.EC2_instance_name
    region = "us-west-2"
  }
}