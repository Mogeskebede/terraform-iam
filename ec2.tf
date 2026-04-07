# DATA SOURCES

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


# USER DATA

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
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>AWS Services Overview - Moges Kebedew</title>

<style>
    body {
        margin: 0;
        font-family: Arial, sans-serif;
        background: linear-gradient(135deg, #1f4037, #99f2c8);
        color: #fff;
    }

    .container {
        max-width: 1100px;
        margin: 40px auto;
        background: rgba(255,255,255,0.95);
        color: #222;
        border-radius: 16px;
        padding: 30px;
        box-shadow: 0 10px 40px rgba(0,0,0,0.2);
    }

    h1 {
        text-align: center;
        margin-bottom: 5px;
    }

    p.subtitle {
        text-align: center;
        color: #555;
        margin-bottom: 25px;
    }

    .grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
        gap: 18px;
    }

    .card {
        background: #ffffff;
        border-radius: 12px;
        padding: 18px;
        text-align: center;
        box-shadow: 0 4px 15px rgba(0,0,0,0.08);
        transition: 0.3s ease;
        cursor: pointer;
        border: 1px solid #eee;
    }

    .card:hover {
        transform: translateY(-6px);
        box-shadow: 0 10px 25px rgba(0,0,0,0.15);
    }

    .icon {
        width: 50px;
        height: 50px;
        margin-bottom: 10px;
    }

    .name {
        font-weight: bold;
        margin-bottom: 5px;
    }

    .desc {
        font-size: 13px;
        color: #666;
    }

    .footer {
        text-align: center;
        margin-top: 25px;
        font-size: 12px;
        color: #777;
    }
</style>
</head>

<body>

<div class="container">
    <h1>AWS Services Overview</h1>
    <p class="subtitle">
        DevOps Automation • Infrastructure as Code • Cloud Deployment <br/>
        Deployed by <b>Moges Kebedew</b>
    </p>

    <div class="grid" id="serviceGrid"></div>

    <div class="footer">
        Deployed via Terraform on AWS EC2 • Interactive DevOps Dashboard
    </div>
</div>

<script>
const services = [
    { name: "EC2", desc: "Elastic Compute Cloud", link: "https://aws.amazon.com/ec2/" },
    { name: "S3", desc: "Simple Storage Service", link: "https://aws.amazon.com/s3/" },
    { name: "RDS", desc: "Relational Database Service", link: "https://aws.amazon.com/rds/" },
    { name: "DynamoDB", desc: "NoSQL Database", link: "https://aws.amazon.com/dynamodb/" },
    { name: "EKS", desc: "Kubernetes Service", link: "https://aws.amazon.com/eks/" },
    { name: "ECS", desc: "Container Service", link: "https://aws.amazon.com/ecs/" },
    { name: "Lambda", desc: "Serverless Compute", link: "https://aws.amazon.com/lambda/" },
    { name: "VPC", desc: "Virtual Private Cloud", link: "https://aws.amazon.com/vpc/" },
    { name: "CloudWatch", desc: "Monitoring Service", link: "https://aws.amazon.com/cloudwatch/" },
    { name: "IAM", desc: "Identity Management", link: "https://aws.amazon.com/iam/" },
    { name: "CloudFront", desc: "CDN Service", link: "https://aws.amazon.com/cloudfront/" },
    { name: "Route 53", desc: "DNS Service", link: "https://aws.amazon.com/route53/" }
];

// FIX: Escape Terraform interpolation using $$
function getIcon(name) {
    return `
    <svg class="icon" viewBox="0 0 24 24" fill="none">
        <rect x="3" y="3" width="18" height="18" rx="4" fill="#FF9900"/>
        <text x="50%" y="55%" text-anchor="middle" fill="white" font-size="7" font-family="Arial">$$\{name}</text>
    </svg>`;
}

const grid = document.getElementById("serviceGrid");

services.forEach(s => {
    const card = document.createElement("div");
    card.className = "card";
    card.onclick = () => window.open(s.link, "_blank");

    card.innerHTML = `
        $${getIcon("$$\{s.name}")} 
        <div class="name">$$\{s.name}</div>
        <div class="desc">$$\{s.desc}</div>
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
  ami                         = data.aws_ami.amazon_linux_1.id
  instance_type               = "t3.micro"
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.sg_use1.id]
  user_data                   = local.user_data

  tags = {
    Name = "ec2-us-east-1"
  }
}

resource "aws_instance" "ec2_use2" {
  provider                    = aws.use2
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = "t3.micro"
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.use2_sg.id]
  user_data                   = local.user_data

  tags = {
    Name = "ec2-us-east-2"
  }
}


# ALB - us-east-1

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


# ALB - us-east-2

resource "aws_lb" "alb_use2" {
  provider           = aws.use2
  name               = "alb-use2"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  security_groups    = [aws_security_group.use2_sg.id]
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