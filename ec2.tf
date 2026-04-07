
# DATA SOURCES


data "aws_vpc" "default" {
  default = true
}

data "aws_vpc" "default_use2" {
  provider = aws.use2
  default  = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_subnets" "default_use2" {
  provider = aws.use2

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default_use2.id]
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
  name   = "use1-sg"
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

resource "aws_security_group" "use2_sg" {
  provider = aws.use2
  name     = "use2-sg"
  vpc_id   = data.aws_vpc.default_use2.id

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


# USER DATA (FULLY FIXED)


locals {
  user_data = <<-EOF
#!/bin/bash
dnf update -y
dnf install -y httpd

systemctl start httpd
systemctl enable httpd

# Health check endpoint
echo "OK" > /var/www/html/health

cat <<'HTML' > /var/www/html/index.html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>AWS Services Overview</title>

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

<style>
body {
  margin:0;
  font-family:Arial;
  background: linear-gradient(135deg,#1f4037,#99f2c8);
  color:#333;
}
.container {
  max-width:1100px;
  margin:50px auto;
  background:#fff;
  padding:30px;
  border-radius:16px;
  box-shadow:0 10px 30px rgba(0,0,0,0.2);
}
h1 { text-align:center; }
.subtitle {
  text-align:center;
  color:gray;
  margin-bottom:30px;
}
.grid {
  display:grid;
  grid-template-columns:repeat(auto-fit,minmax(220px,1fr));
  gap:20px;
}
.card {
  padding:20px;
  border-radius:12px;
  background:linear-gradient(145deg,#f9f9f9,#e6e6e6);
  text-align:center;
  cursor:pointer;
  transition:all 0.3s ease;
}
.card:hover {
  transform:translateY(-8px) scale(1.03);
  box-shadow:0 10px 20px rgba(0,0,0,0.15);
}
.icon {
  font-size:30px;
  margin-bottom:10px;
  color:#2c7be5;
}
.name {
  font-weight:bold;
  font-size:18px;
}
.desc {
  font-size:14px;
  color:gray;
}
</style>
</head>

<body>

<div class="container">
  <h1>AWS Services Overview</h1>
  <div class="subtitle">Deployed by Moges Kebedew</div>
  <div class="grid" id="serviceGrid"></div>
</div>

<script>
const services = [
 { name:"EC2", desc:"Compute", icon:"fa-server", link:"https://aws.amazon.com/ec2/" },
 { name:"S3", desc:"Storage", icon:"fa-database", link:"https://aws.amazon.com/s3/" },
 { name:"Lambda", desc:"Serverless", icon:"fa-bolt", link:"https://aws.amazon.com/lambda/" },
 { name:"VPC", desc:"Networking", icon:"fa-network-wired", link:"https://aws.amazon.com/vpc/" },
 { name:"RDS", desc:"Database", icon:"fa-database", link:"https://aws.amazon.com/rds/" },
 { name:"CloudWatch", desc:"Monitoring", icon:"fa-chart-line", link:"https://aws.amazon.com/cloudwatch/" }
];

const grid=document.getElementById("serviceGrid");

services.forEach(s=>{
 const card=document.createElement("div");
 card.className="card";
 card.onclick=()=>window.open(s.link,"_blank");

 card.innerHTML = `
   <div class="icon"><i class="fa $${s.icon}"></i></div>
   <div class="name">$${s.name}</div>
   <div class="desc">$${s.desc}</div>
 `;
 grid.appendChild(card);
});
</script>

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
  user_data              = local.user_data

  tags = { Name = "ec2-us-east-1" }
}

resource "aws_instance" "ec2_use2" {
  provider               = aws.use2
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t3.micro"
  subnet_id              = data.aws_subnets.default_use2.ids[0]
  vpc_security_group_ids = [aws_security_group.use2_sg.id]
  user_data              = local.user_data

  tags = { Name = "ec2-us-east-2" }
}


# LOAD BALANCERS


resource "aws_lb" "alb_use1" {
  name               = "alb-use1"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  security_groups    = [aws_security_group.sg_use1.id]
}

resource "aws_lb" "alb_use2" {
  provider           = aws.use2
  name               = "alb-use2"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default_use2.ids
  security_groups    = [aws_security_group.use2_sg.id]
}


# TARGET GROUPS (FIXED HEALTH CHECKS)


resource "aws_lb_target_group" "tg_use1" {
  name     = "tg-use1"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    enabled             = true
    protocol            = "HTTP"
    path                = "/health"
    port                = "traffic-port"
    matcher             = "200"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
  }
}

resource "aws_lb_target_group" "tg_use2" {
  provider = aws.use2
  name     = "tg-use2"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default_use2.id

  health_check {
    enabled             = true
    protocol            = "HTTP"
    path                = "/health"
    port                = "traffic-port"
    matcher             = "200"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
  }
}


# TARGET GROUP ATTACHMENTS


resource "aws_lb_target_group_attachment" "attach_use1" {
  target_group_arn = aws_lb_target_group.tg_use1.arn
  target_id        = aws_instance.ec2_use1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "attach_use2" {
  provider         = aws.use2
  target_group_arn = aws_lb_target_group.tg_use2.arn
  target_id        = aws_instance.ec2_use2.id
  port             = 80
}


# LISTENERS


resource "aws_lb_listener" "listener_use1" {
  load_balancer_arn = aws_lb.alb_use1.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_use1.arn
  }
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
  provider     = aws.use2
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