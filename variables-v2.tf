variable "access_key" {}

variable "secret_key" {}

variable "key_name" {}

variable "region" {
    description = "EC2 Region for the VPC"
    default = "us-east-1"
}

variable "vpc_cidr" {
    default = "14.0.0.0/16" 
}

variable "privatesubnet_cidrblocks" {
    type = list 
    default = ["14.0.1.0/24","14.0.2.0/24","14.0.3.0/24","14.0.4.0/24"] 
}

variable "publicsubnet_cidrblocks" {
    type = list 
    default = ["14.0.5.0/24","14.0.6.0/24"] 
}


variable "cidr_block" {
  default = "0.0.0.0/0"
}


variable "amis" {
  description = "Base AMI to launch the instances"
  default = {
  us-east-1 = "ami-0b898040803850657"
  }
}


# variable "amis" {
#   description = "Base AMI to launch the instances"
# }

variable "instance_type" {
  default = "t2.micro"
}

variable "password" {
  default = "Coth123456"  
}

variable "grace_period" {
  default = 300
}

variable "healthy_threshold" {
  default = 10
}

variable "unhealthy_threshold" {
  default = 10
}

variable "timeout" {
  default = 5
}

variable "interval" {
  default = 300
}


variable "http_port" {
  default = 80
}


# variable "AMIS" {
#   type = "map"
#   default = {
#     us-east-1 = "ami-13be557e"
#     us-west-2 = "ami-06b94666"
#     eu-west-1 = "ami-844e0bf7"
#   }
# }