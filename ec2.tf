# DATA SOURCES (DEFAULT VPC + SUBNETS)


data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_ami" "amazon_linux_1" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

data "aws_ami" "amazon_linux_2" {
  provider    = aws.use2
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}


# SECURITY GROUPS


resource "aws_security_group" "sg_use1" {
  name   = "sg-use1"
  vpc_id = data.aws_vpc.default.id

  ingress {
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

resource "aws_security_group" "sg_use2" {
  provider = aws.use2
  name     = "sg-use2"
  vpc_id   = data.aws_vpc.default.id

  ingress {
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


# USER DATA (YOUR HTML DASHBOARD)


locals {
  user_data = <<-EOF
#!/bin/bash
dnf update -y
dnf install -y httpd

systemctl start httpd
systemctl enable httpd

REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)

cat <<HTML > /var/www/html/index.html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>AWS Services Dashboard</title>

<style>
body {
    margin: 0;
    font-family: 'Segoe UI', sans-serif;
    background: linear-gradient(135deg, #0f2027, #2c5364);
}

.container {
    max-width: 1100px;
    margin: 50px auto;
    background: rgba(255,255,255,0.95);
    padding: 30px;
    border-radius: 16px;
    box-shadow: 0 20px 40px rgba(0,0,0,0.3);
}

h1 {
    text-align: center;
    color: #232f3e;
}

.badge {
    text-align: center;
    color: #ff9900;
    font-weight: bold;
}

.engineer {
    text-align: center;
    margin: 10px 0;
}

.region {
    text-align: center;
    font-weight: bold;
    color: #2c5364;
    margin-bottom: 10px;
}

.search-box {
    margin: 20px 0;
    text-align: center;
}

.search-box input {
    width: 60%;
    padding: 10px;
    border-radius: 8px;
    border: 1px solid #ccc;
    font-size: 16px;
}

table {
    width: 100%;
    border-collapse: collapse;
}

th {
    background: #232f3e;
    color: white;
    padding: 12px;
}

td {
    padding: 12px;
    border-bottom: 1px solid #ddd;
}

tr:hover {
    background-color: #e3f2fd;
}

.service img {
    width: 22px;
    vertical-align: middle;
    margin-right: 10px;
}
</style>
</head>

<body>
<div class="container">
    <h1>AWS Services Dashboard</h1>

    <div class="badge">
        DevOps Automation • Infrastructure as Code • Cloud Engineering
    </div>

    <div class="engineer">
        Engineered by <strong>Moges Kebedew</strong>
    </div>

    <div class="region">
        Served from region: <span id="region">${REGION}</span>
    </div>

    <table>
        <tr>
            <th>Service</th>
            <th>Description</th>
            <th>Benefit</th>
        </tr>

        <tr>
            <td><img src="https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/v14.0/PNG/Light/Compute/Amazon-EC2_light-bg.png">EC2</td>
            <td>Elastic Compute Cloud</td>
            <td>Scalable servers</td>
        </tr>

        <tr>
            <td><img src="https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/v14.0/PNG/Light/Storage/Amazon-S3_light-bg.png">S3</td>
            <td>Object Storage</td>
            <td>Highly durable storage</td>
        </tr>
    </table>
</div>
</body>
</html>
HTML
EOF
}


# EC2 INSTANCES


resource "aws_instance" "ec2_use1" {
  ami                    = data.aws_ami.amazon_linux_1.id
  instance_type          = "t3.micro"
  subnet_id              = data.aws_subnets.default.ids[0]
  vpc_security_group_ids = [aws_security_group.sg_use1.id]

  user_data = local.user_data

  tags = {
    Name = "ec2-us-east-1"
  }
}

resource "aws_instance" "ec2_use2" {
  provider               = aws.use2
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t3.micro"
  subnet_id              = data.aws_subnets.default.ids[0]
  vpc_security_group_ids = [aws_security_group.sg_use2.id]

  user_data = local.user_data

  tags = {
    Name = "ec2-us-east-2"
  }
}


# ALB - US EAST 1


resource "aws_lb" "alb_use1" {
  name               = "alb-use1"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  security_groups    = [aws_security_group.sg_use1.id]
}

resource "aws_lb_target_group" "tg_use1" {
  name     = "tg-use1"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id
}

resource "aws_lb_target_group_attachment" "attach_use1" {
  target_group_arn = aws_lb_target_group.tg_use1.arn
  target_id        = aws_instance.ec2_use1.id
  port             = 80
}

resource "aws_lb_listener" "listener_use1" {
  load_balancer_arn = aws_lb.alb_use1.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_use1.arn
  }
}


# ALB - US EAST 2


resource "aws_lb" "alb_use2" {
  provider           = aws.use2
  name               = "alb-use2"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  security_groups    = [aws_security_group.sg_use2.id]
}

resource "aws_lb_target_group" "tg_use2" {
  provider = aws.use2
  name     = "tg-use2"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id
}

resource "aws_lb_target_group_attachment" "attach_use2" {
  provider         = aws.use2
  target_group_arn = aws_lb_target_group.tg_use2.arn
  target_id        = aws_instance.ec2_use2.id
  port             = 80
}

resource "aws_lb_listener" "listener_use2" {
  provider          = aws.use2
  load_balancer_arn = aws_lb.alb_use2.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_use2.arn
  }
}


# GLOBAL ACCELERATOR


resource "aws_globalaccelerator_accelerator" "ga" {
  name            = "multi-region-ga"
  ip_address_type = "IPV4"
  enabled         = true
}

resource "aws_globalaccelerator_listener" "ga_listener" {
  accelerator_arn = aws_globalaccelerator_accelerator.ga.id
  protocol        = "TCP"

  port_range {
    from_port = 80
    to_port   = 80
  }
}

resource "aws_globalaccelerator_endpoint_group" "eg_use1" {
  listener_arn = aws_globalaccelerator_listener.ga_listener.id

  endpoint_configuration {
    endpoint_id = aws_lb.alb_use1.arn
    weight      = 100
  }
}

resource "aws_globalaccelerator_endpoint_group" "eg_use2" {
  listener_arn = aws_globalaccelerator_listener.ga_listener.id

  endpoint_configuration {
    endpoint_id = aws_lb.alb_use2.arn
    weight      = 100
  }
}


# OUTPUT


output "global_accelerator_dns" {
  value = aws_globalaccelerator_accelerator.ga.dns_name
}