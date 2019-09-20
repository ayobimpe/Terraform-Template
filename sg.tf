# Define the security group for public subnet
resource "aws_security_group" "websg" {
  name = "webserversg"
  description = "Allow incoming HTTP connections & SSH access"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_groups = ["${aws_security_group.elbsg.id}"]
  }


  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    security_groups = ["${aws_security_group.elbsg.id}"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    self = false
  }


  vpc_id="${aws_vpc.bimps_vpc.id}"

  tags = {
    Name = "Web Server SG"
  }
}

# Define the security group for private subnet
resource "aws_security_group" "appserversg"{
  name = "appserver"
  description = "Allow traffic from public subnet"

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_groups = ["${aws_security_group.websg.id}"]
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    security_groups = ["${aws_security_group.websg.id}"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    self = false
  }

  vpc_id = "${aws_vpc.bimps_vpc.id}"

  tags = {
    Name = "Appserver SG"
  }
}

# Define the security group for Load Balancer
resource "aws_security_group" "elbsg"{
  name = "load_balancer"
  description = "Allow all"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    self = false
  }

  vpc_id="${aws_vpc.bimps_vpc.id}"

  tags = {
    Name = "Load Balancer SG"
  }
}