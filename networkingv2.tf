data "aws_availability_zones" "az" {
  state = "available"
}


resource "aws_vpc" "bimps_vpc" {
  cidr_block         = "${var.vpc_cidr}"
  enable_dns_hostnames = "true"

  tags = {
    Name = "bimps_vpc"
  }
}


resource "aws_subnet" "public-subnet" {
  vpc_id = "${aws_vpc.bimps_vpc.id}"
  count   = length(var.publicsubnet_cidrblocks)
  cidr_block = "${element(var.publicsubnet_cidrblocks, count.index)}"
  availability_zone = "${data.aws_availability_zones.az.names[count.index]}"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "public-subnet${count.index + 1} "
  }
}


resource "aws_subnet" "private-subnet" {
  vpc_id = "${aws_vpc.bimps_vpc.id}"
  count   = length(var.privatesubnet_cidrblocks)
  cidr_block = "${element(var.privatesubnet_cidrblocks, count.index)}"
  availability_zone = "${data.aws_availability_zones.az.names[count.index]}"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "private-subnet${count.index + 1} "
  }
}

# Define internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.bimps_vpc.id}"

  tags = {
    Name = "Bimps VPC IGW"
  }
}

# Create Elastic IP to assign to NAT Gateway
resource "aws_eip" "EIP" {
  vpc      = true
  depends_on = ["aws_internet_gateway.gw"]
  }

# Create nat gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.EIP.id}"
  subnet_id = "${aws_subnet.public-subnet.*.id[0]}"
#   subnet_id =  "${aws_subnet.public-subnet.*.id[0]}"
  depends_on = ["aws_internet_gateway.gw"]

  tags = {
    Name = "Bimps NAT GW"
  }
}

# Create Public route table
resource "aws_route_table" "web-public-rt" {
  vpc_id = "${aws_vpc.bimps_vpc.id}"

  route {
    cidr_block = "${var.cidr_block}"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags = {
    Name = "Public Subnet RT"
  }
}

# Create private route table and the route to the internet 
resource "aws_route_table" "private-rt" {
  vpc_id = "${aws_vpc.bimps_vpc.id}"
  
  tags = {
    Name = "Private Subnet RT"
  }
}

resource "aws_route" "private_route" {
   route_table_id  = "${aws_route_table.private-rt.id}"
   destination_cidr_block = "${var.cidr_block}"
   nat_gateway_id = "${aws_nat_gateway.nat.id}"
} 

resource "aws_route_table_association" "public-subnet_association" {
  count   = "${length(aws_subnet.public-subnet.*.id)}"
  subnet_id  = "${element(aws_subnet.public-subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.web-public-rt.id}"
}

resource "aws_route_table_association" "private-subnet_association" {
  count   = "${length(aws_subnet.private-subnet.*.id)}"
  subnet_id  = "${element(aws_subnet.private-subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.private-rt.id}"
}