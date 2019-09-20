resource "aws_security_group" "rdssg" {
  name = "rds-sg"
  description = "allow connection to db instance"

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_groups = ["${aws_security_group.appserversg.id}"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    self = true
  }

  vpc_id="${aws_vpc.bimps_vpc.id}"

  tags = {
    Name = "RDS SG"
  }
}
resource "aws_db_subnet_group" "bimpssubnetgrp" {
  name       = "mysql-subnet"
  description = "RDS subnet group"
  subnet_ids  = ["${aws_subnet.private-subnet.*.id[2]}","${aws_subnet.private-subnet.*.id[3]}"]
  # subnet_ids = ["${aws_subnet.private-subnet3.id}", "${aws_subnet.private-subnet4.id}"]

  tags = {
    Name = "My DB subnet group"
  }
}
resource "aws_db_instance" "bimpsdb" {
  allocated_storage    = 20
  storage_type         = "gp2"
  db_subnet_group_name     = "${aws_db_subnet_group.bimpssubnetgrp.id}"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  multi_az             = true
  maintenance_window   = "Sun:05:00-Sun:06:00"
  backup_window        = "09:46-10:16"
  backup_retention_period = 0
  identifier           = "test"
  name                 = "mydb"
  username             = "bimpsdb"
  password             = "${var.password}"
  parameter_group_name = "default.mysql5.7"
  vpc_security_group_ids = ["${aws_security_group.rdssg.id}"]
  skip_final_snapshot  = true
}