data "aws_ami_ids" "amis" {
  owners = ["amazon"]
}

resource "aws_launch_configuration" "weblaunch-config" { 
    # image_id               = "${data.aws_ami_ids.ids}"
    image_id               = "${lookup(var.amis,var.region)}"
    instance_type          = "t2.micro"
    security_groups        = ["${aws_security_group.websg.id}"]
    key_name               = "${var.key_name}"
    user_data = <<-EOF
                #!/bin/bash
                sudo yum update
                sudo yum install httpd -y
                sudo systemctl start httpd
                sudo systemctl enable httpd
                echo "Hello ,world" > index.html
                EOF
    lifecycle {
      create_before_destroy = true
    }
  }

resource "aws_launch_configuration" "applaunch-config" {
    image_id               = "${lookup(var.amis,var.region)}"
    # image_id               = "${data.aws_ami_ids.ids}"
    instance_type          = "t2.micro"
    security_groups        = ["${aws_security_group.appserversg.id}"]
    key_name               = "${var.key_name}"
    lifecycle {
      create_before_destroy = true
    }
  }


  resource "aws_autoscaling_group" "webserver-asg" {
    launch_configuration = "${aws_launch_configuration.weblaunch-config.id}"
    vpc_zone_identifier       = ["${aws_subnet.public-subnet.*.id[0]}","${aws_subnet.public-subnet.*.id[1]}"]
    min_size = 1
    max_size = 2
    load_balancers = ["${aws_elb.public-elb.name}"]
    health_check_grace_period = "${var.grace_period}"
    health_check_type = "ELB"
    tags = [ {
      key                 = "Name"
      value               = "webserver-asg"
      propagate_at_launch = true
   }]
  }

  resource "aws_autoscaling_group" "appserver-asg" {
    launch_configuration = "${aws_launch_configuration.applaunch-config.id}"
    vpc_zone_identifier       = ["${aws_subnet.private-subnet.*.id[0]}","${aws_subnet.private-subnet.*.id[1]}"]
    # vpc_zone_identifier       = ["${aws_subnet.private-subnet.id}", "${aws_subnet.private-subnet.id}"]
    min_size = 1
    max_size = 2
    load_balancers = ["${aws_elb.private-elb.name}"]
    health_check_grace_period = "${var.grace_period}"
    health_check_type = "ELB"
    tags = [ {
      key                 = "Name"
      value               = "appserver-asg"
      propagate_at_launch = true
   }]
  }


  ### Creating ELB
  resource "aws_elb" "public-elb" {
    name	 = "internet-facing"
    security_groups = ["${aws_security_group.elbsg.id}"]
    subnets            = ["${aws_subnet.public-subnet.*.id[0]}","${aws_subnet.public-subnet.*.id[1]}"]
    internal           = false
    cross_zone_load_balancing   = true
      health_check {
      healthy_threshold = "${var.healthy_threshold}"
      unhealthy_threshold = "${var.unhealthy_threshold}"
      timeout = "${var.timeout}"
      interval = "${var.interval}"
      target = "HTTP:80/index.html"
    }
    listener {
      lb_port = 80
      lb_protocol = "http"
      instance_port = "80"
      instance_protocol = "http"
    }
  }

  resource "aws_elb" "private-elb" {
    name	 = "internal"
    security_groups = ["${aws_security_group.elbsg.id}"]
    subnets            = ["${aws_subnet.private-subnet.*.id[0]}","${aws_subnet.private-subnet.*.id[1]}"]
    internal           = true
    cross_zone_load_balancing   = true
      health_check {
      healthy_threshold = "${var.healthy_threshold}"
      unhealthy_threshold = "${var.unhealthy_threshold}"
      timeout = "${var.timeout}"
      interval = "${var.interval}"
      target = "HTTP:80/index.html"
    }
    listener {
      lb_port = "${var.http_port}"
      lb_protocol = "http"
      instance_port = "80"
      instance_protocol = "http"
    }
  }
