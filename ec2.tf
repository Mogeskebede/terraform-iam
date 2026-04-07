
# VPC + NETWORKING (us-east-1)


resource "aws_vpc" "use1" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "use1-vpc" }
}

resource "aws_internet_gateway" "use1_igw" {
  vpc_id = aws_vpc.use1.id
  tags   = { Name = "use1-igw" }
}

resource "aws_subnet" "use1_public_a" {
  vpc_id                  = aws_vpc.use1.id
  cidr_block              = "10.10.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = { Name = "use1-public-a" }
}

resource "aws_subnet" "use1_public_b" {
  vpc_id                  = aws_vpc.use1.id
  cidr_block              = "10.10.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = { Name = "use1-public-b" }
}

resource "aws_subnet" "use1_private_a" {
  vpc_id            = aws_vpc.use1.id
  cidr_block        = "10.10.11.0/24"
  availability_zone = "us-east-1a"
  tags = { Name = "use1-private-a" }
}

resource "aws_subnet" "use1_private_b" {
  vpc_id            = aws_vpc.use1.id
  cidr_block        = "10.10.12.0/24"
  availability_zone = "us-east-1b"
  tags = { Name = "use1-private-b" }
}

resource "aws_eip" "use1_nat_eip" {
  domain = "vpc"
  tags   = { Name = "use1-nat-eip" }
}

resource "aws_nat_gateway" "use1_nat" {
  allocation_id = aws_eip.use1_nat_eip.id
  subnet_id     = aws_subnet.use1_public_a.id

  tags = { Name = "use1-nat" }
}

resource "aws_route_table" "use1_public_rt" {
  vpc_id = aws_vpc.use1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.use1_igw.id
  }

  tags = { Name = "use1-public-rt" }
}

resource "aws_route_table_association" "use1_public_a_assoc" {
  subnet_id      = aws_subnet.use1_public_a.id
  route_table_id = aws_route_table.use1_public_rt.id
}

resource "aws_route_table_association" "use1_public_b_assoc" {
  subnet_id      = aws_subnet.use1_public_b.id
  route_table_id = aws_route_table.use1_public_rt.id
}

resource "aws_route_table" "use1_private_rt" {
  vpc_id = aws_vpc.use1.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.use1_nat.id
  }

  tags = { Name = "use1-private-rt" }
}

resource "aws_route_table_association" "use1_private_a_assoc" {
  subnet_id      = aws_subnet.use1_private_a.id
  route_table_id = aws_route_table.use1_private_rt.id
}

resource "aws_route_table_association" "use1_private_b_assoc" {
  subnet_id      = aws_subnet.use1_private_b.id
  route_table_id = aws_route_table.use1_private_rt.id
}


# VPC + NETWORKING (us-east-2)


resource "aws_vpc" "use2" {
  provider              = aws.use2
  cidr_block            = "10.20.0.0/16"
  enable_dns_support    = true
  enable_dns_hostnames  = true
  tags                  = { Name = "use2-vpc" }
}

resource "aws_internet_gateway" "use2_igw" {
  provider = aws.use2
  vpc_id   = aws_vpc.use2.id
  tags     = { Name = "use2-igw" }
}

resource "aws_subnet" "use2_public_a" {
  provider                = aws.use2
  vpc_id                  = aws_vpc.use2.id
  cidr_block              = "10.20.1.0/24"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true
  tags = { Name = "use2-public-a" }
}

resource "aws_subnet" "use2_public_b" {
  provider                = aws.use2
  vpc_id                  = aws_vpc.use2.id
  cidr_block              = "10.20.2.0/24"
  availability_zone       = "us-east-2b"
  map_public_ip_on_launch = true
  tags = { Name = "use2-public-b" }
}

resource "aws_subnet" "use2_private_a" {
  provider          = aws.use2
  vpc_id            = aws_vpc.use2.id
  cidr_block        = "10.20.11.0/24"
  availability_zone = "us-east-2a"
  tags = { Name = "use2-private-a" }
}

resource "aws_subnet" "use2_private_b" {
  provider          = aws.use2
  vpc_id            = aws_vpc.use2.id
  cidr_block        = "10.20.12.0/24"
  availability_zone = "us-east-2b"
  tags = { Name = "use2-private-b" }
}

resource "aws_eip" "use2_nat_eip" {
  provider = aws.use2
  domain   = "vpc"
  tags     = { Name = "use2-nat-eip" }
}

resource "aws_nat_gateway" "use2_nat" {
  provider      = aws.use2
  allocation_id = aws_eip.use2_nat_eip.id
  subnet_id     = aws_subnet.use2_public_a.id

  tags = { Name = "use2-nat" }
}

resource "aws_route_table" "use2_public_rt" {
  provider = aws.use2
  vpc_id   = aws_vpc.use2.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.use2_igw.id
  }

  tags = { Name = "use2-public-rt" }
}

resource "aws_route_table_association" "use2_public_a_assoc" {
  provider       = aws.use2
  subnet_id      = aws_subnet.use2_public_a.id
  route_table_id = aws_route_table.use2_public_rt.id
}

resource "aws_route_table_association" "use2_public_b_assoc" {
  provider       = aws.use2
  subnet_id      = aws_subnet.use2_public_b.id
  route_table_id = aws_route_table.use2_public_rt.id
}

resource "aws_route_table" "use2_private_rt" {
  provider = aws.use2
  vpc_id   = aws_vpc.use2.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.use2_nat.id
  }

  tags = { Name = "use2-private-rt" }
}

resource "aws_route_table_association" "use2_private_a_assoc" {
  provider       = aws.use2
  subnet_id      = aws_subnet.use2_private_a.id
  route_table_id = aws_route_table.use2_private_rt.id
}

resource "aws_route_table_association" "use2_private_b_assoc" {
  provider       = aws.use2
  subnet_id      = aws_subnet.use2_private_b.id
  route_table_id = aws_route_table.use2_private_rt.id
}


# AMIs


data "aws_ami" "amazon_linux_use1" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

data "aws_ami" "amazon_linux_use2" {
  provider    = aws.use2
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}


# SECURITY GROUPS


resource "aws_security_group" "use1_alb_sg" {
  name   = "use1-alb-sg"
  vpc_id = aws_vpc.use1.id

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

  tags = { Name = "use1-alb-sg" }
}

resource "aws_security_group" "use1_ec2_sg" {
  name   = "use1-ec2-sg"
  vpc_id = aws_vpc.use1.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.use1_alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "use1-ec2-sg" }
}

resource "aws_security_group" "use2_alb_sg" {
  provider = aws.use2
  name     = "use2-alb-sg"
  vpc_id   = aws_vpc.use2.id

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

  tags = { Name = "use2-alb-sg" }
}

resource "aws_security_group" "use2_ec2_sg" {
  provider = aws.use2
  name     = "use2-ec2-sg"
  vpc_id   = aws_vpc.use2.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.use2_alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "use2-ec2-sg" }
}


# USER DATA


locals {
  user_data = <<-EOF
#!/bin/bash
dnf update -y
dnf install -y httpd

systemctl start httpd
systemctl enable httpd

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
 { name:"EC2",           desc:"Virtual servers in the cloud",          icon:"fa-server",        link:"https://aws.amazon.com/ec2/" },
 { name:"S3",            desc:"Object storage service",                icon:"fa-database",      link:"https://aws.amazon.com/s3/" },
 { name:"Lambda",        desc:"Serverless compute",                    icon:"fa-bolt",          link:"https://aws.amazon.com/lambda/" },
 { name:"VPC",           desc:"Isolated cloud networks",               icon:"fa-network-wired", link:"https://aws.amazon.com/vpc/" },
 { name:"RDS",           desc:"Managed relational databases",          icon:"fa-database",      link:"https://aws.amazon.com/rds/" },
 { name:"DynamoDB",      desc:"NoSQL key-value database",              icon:"fa-table",         link:"https://aws.amazon.com/dynamodb/" },
 { name:"API Gateway",   desc:"Managed API endpoints",                 icon:"fa-plug",          link:"https://aws.amazon.com/api-gateway/" },
 { name:"ECS",           desc:"Container orchestration",               icon:"fa-boxes-stacked", link:"https://aws.amazon.com/ecs/" },
 { name:"EKS",           desc:"Managed Kubernetes",                    icon:"fa-boxes-stacked", link:"https://aws.amazon.com/eks/" },
 { name:"CloudFront",    desc:"Content delivery network",              icon:"fa-globe",         link:"https://aws.amazon.com/cloudfront/" },
 { name:"Route 53",      desc:"DNS and traffic management",            icon:"fa-location-arrow",link:"https://aws.amazon.com/route53/" },
 { name:"IAM",           desc:"Identity and access management",        icon:"fa-user-shield",   link:"https://aws.amazon.com/iam/" },
 { name:"CloudWatch",    desc:"Monitoring and observability",          icon:"fa-chart-line",    link:"https://aws.amazon.com/cloudwatch/" },
 { name:"CloudTrail",    desc:"API activity logging",                  icon:"fa-shoe-prints",   link:"https://aws.amazon.com/cloudtrail/" },
 { name:"SNS",           desc:"Pub/Sub notifications",                 icon:"fa-bell",          link:"https://aws.amazon.com/sns/" },
 { name:"SQS",           desc:"Message queuing",                       icon:"fa-envelope",      link:"https://aws.amazon.com/sqs/" },
 { name:"Kinesis",       desc:"Real-time data streaming",              icon:"fa-wave-square",   link:"https://aws.amazon.com/kinesis/" },
 { name:"Redshift",      desc:"Data warehousing",                      icon:"fa-database",      link:"https://aws.amazon.com/redshift/" },
 { name:"ElastiCache",   desc:"In-memory caching",                     icon:"fa-memory",        link:"https://aws.amazon.com/elasticache/" },
 { name:"Elastic Beanstalk", desc:"PaaS for web apps",                 icon:"fa-leaf",          link:"https://aws.amazon.com/elasticbeanstalk/" },
 { name:"WAF",           desc:"Web application firewall",              icon:"fa-shield-halved", link:"https://aws.amazon.com/waf/" },
 { name:"Shield",        desc:"DDoS protection",                       icon:"fa-shield",        link:"https://aws.amazon.com/shield/" },
 { name:"Glue",          desc:"Serverless data integration",           icon:"fa-broom",         link:"https://aws.amazon.com/glue/" },
 { name:"Step Functions",desc:"Serverless workflows",                  icon:"fa-diagram-project",link:"https://aws.amazon.com/step-functions/" },
 { name:"Secrets Manager",desc:"Secure secret storage",                icon:"fa-key",           link:"https://aws.amazon.com/secrets-manager/" },
 { name:"KMS",           desc:"Key management service",                icon:"fa-lock",          link:"https://aws.amazon.com/kms/" }
];
const grid = document.getElementById("serviceGrid");
services.forEach(s => {
  const card = document.createElement("div");
  card.className = "card";
  card.onclick = () => window.open(s.link, "_blank");
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


# EC2 INSTANCES (PRIVATE SUBNETS)


resource "aws_instance" "use1_ec2" {
  ami                         = data.aws_ami.amazon_linux_use1.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.use1_private_a.id
  vpc_security_group_ids      = [aws_security_group.use1_ec2_sg.id]
  user_data                   = local.user_data
  user_data_replace_on_change = true

  tags = { Name = "ec2-us-east-1" }
}

resource "aws_instance" "use2_ec2" {
  provider                    = aws.use2
  ami                         = data.aws_ami.amazon_linux_use2.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.use2_private_a.id
  vpc_security_group_ids      = [aws_security_group.use2_ec2_sg.id]
  user_data                   = local.user_data
  user_data_replace_on_change = true

  tags = { Name = "ec2-us-east-2" }
}


# ALBs (PUBLIC SUBNETS)


resource "aws_lb" "use1_alb" {
  name               = "use1-alb"
  load_balancer_type = "application"
  subnets            = [aws_subnet.use1_public_a.id, aws_subnet.use1_public_b.id]
  security_groups    = [aws_security_group.use1_alb_sg.id]

  tags = { Name = "use1-alb" }
}

resource "aws_lb" "use2_alb" {
  provider           = aws.use2
  name               = "use2-alb"
  load_balancer_type = "application"
  subnets            = [aws_subnet.use2_public_a.id, aws_subnet.use2_public_b.id]
  security_groups    = [aws_security_group.use2_alb_sg.id]

  tags = { Name = "use2-alb" }
}


# TARGET GROUPS + ATTACHMENTS


resource "aws_lb_target_group" "use1_tg" {
  name     = "use1-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.use1.id

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

  tags = { Name = "use1-tg" }
}

resource "aws_lb_target_group" "use2_tg" {
  provider = aws.use2
  name     = "use2-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.use2.id

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

  tags = { Name = "use2-tg" }
}

resource "aws_lb_target_group_attachment" "use1_attach" {
  target_group_arn = aws_lb_target_group.use1_tg.arn
  target_id        = aws_instance.use1_ec2.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "use2_attach" {
  provider         = aws.use2
  target_group_arn = aws_lb_target_group.use2_tg.arn
  target_id        = aws_instance.use2_ec2.id
  port             = 80
}


# LISTENERS


resource "aws_lb_listener" "use1_listener" {
  load_balancer_arn = aws_lb.use1_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.use1_tg.arn
  }
}

resource "aws_lb_listener" "use2_listener" {
  provider          = aws.use2
  load_balancer_arn = aws_lb.use2_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.use2_tg.arn
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

resource "aws_globalaccelerator_endpoint_group" "ga_use1_eg" {
  listener_arn = aws_globalaccelerator_listener.ga_listener.id

  endpoint_configuration {
    endpoint_id = aws_lb.use1_alb.arn
    weight      = 100
  }
}

resource "aws_globalaccelerator_endpoint_group" "ga_use2_eg" {
  provider     = aws.use2
  listener_arn = aws_globalaccelerator_listener.ga_listener.id

  endpoint_configuration {
    endpoint_id = aws_lb.use2_alb.arn
    weight      = 100
  }
}


# OUTPUT


output "global_accelerator_dns" {
  value = aws_globalaccelerator_accelerator.ga.dns_name
}