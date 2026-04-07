
# Get Latest Amazon Linux AMI

data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}


# Get Default VPC

data "aws_vpc" "default" {
  default = true
}


# Get Subnets from Default VPC

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}


# Security Group (HTTP + SSH)

resource "aws_security_group" "web_sg" {
  name        = "dev-web-sg"
  description = "Allow HTTP and SSH"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #  Restrict in production
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "dev-web-sg"
  }
}


# EC2 Instance (Web Server)

resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

  subnet_id = data.aws_subnets.default.ids[0]

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y httpd

              systemctl start httpd
              systemctl enable httpd

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
                          font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                          background: linear-gradient(135deg, #1f4037, #99f2c8);
                          color: #333;
                      }

                      .container {
                          max-width: 1000px;
                          margin: 50px auto;
                          background: #ffffff;
                          padding: 30px;
                          border-radius: 12px;
                          box-shadow: 0 10px 25px rgba(0,0,0,0.2);
                      }

                      h1 {
                          text-align: center;
                          color: #232f3e;
                          margin-bottom: 10px;
                          letter-spacing: 1px;
                      }

                      p {
                          text-align: center;
                          color: #555;
                          margin-bottom: 20px;
                          font-size: 16px;
                      }

                      .badge {
                          text-align: center;
                          font-weight: bold;
                          color: #1f4037;
                          margin-bottom: 20px;
                      }

                      table {
                          width: 100%;
                          border-collapse: collapse;
                          border-radius: 10px;
                          overflow: hidden;
                      }

                      th {
                          background: #232f3e;
                          color: white;
                          padding: 14px;
                          text-align: left;
                      }

                      td {
                          padding: 12px;
                          border-bottom: 1px solid #ddd;
                      }

                      tr:nth-child(even) {
                          background-color: #f9f9f9;
                      }

                      tr:hover {
                          background-color: #e6f2ff;
                          transition: 0.3s;
                      }

                      footer {
                          text-align: center;
                          margin-top: 20px;
                          font-size: 12px;
                          color: #777;
                      }
                  </style>
              </head>

              <body>
                  <div class="container">
                      <h1>AWS Services Overview</h1>

                      <div class="badge">
                          DevOps Automation • Infrastructure as Code • Cloud Deployment
                      </div>

                      <p>
                          This web server was automatically provisioned using Terraform in Amazon Web Services (AWS).
                          It demonstrates Infrastructure as Code (IaC) by deploying a fully functional web server
                          that dynamically presents core AWS services and their benefits.
                      </p>

                      <table>
                          <tr>
                              <th>Service</th>
                              <th>Description</th>
                              <th>Key Benefit</th>
                          </tr>

                          <tr><td>EC2</td><td>Elastic Compute Cloud</td><td>Scalable virtual servers</td></tr>
                          <tr><td>S3</td><td>Simple Storage Service</td><td>Highly durable object storage</td></tr>
                          <tr><td>RDS</td><td>Relational Database Service</td><td>Managed SQL databases</td></tr>
                          <tr><td>DynamoDB</td><td>NoSQL Database</td><td>Ultra-fast and serverless</td></tr>
                          <tr><td>EKS</td><td>Kubernetes Service</td><td>Managed container orchestration</td></tr>
                          <tr><td>ECS</td><td>Container Service</td><td>Simple container management</td></tr>
                          <tr><td>Lambda</td><td>Serverless Compute</td><td>No server management</td></tr>
                          <tr><td>VPC</td><td>Virtual Private Cloud</td><td>Network isolation</td></tr>
                          <tr><td>CloudWatch</td><td>Monitoring Service</td><td>Logs and metrics tracking</td></tr>
                          <tr><td>IAM</td><td>Identity Management</td><td>Secure access control</td></tr>
                          <tr><td>CloudFront</td><td>CDN</td><td>Global content delivery</td></tr>
                          <tr><td>Route 53</td><td>DNS Service</td><td>Highly available domain routing</td></tr>
                      </table>

                      <footer>
                          Deployed via Terraform | DevOps Automation Demo
                      </footer>
                  </div>
              </body>
              </html>
              HTML
              EOF

  tags = {
    Name = "dev-web-server"
  }
}


# Output

output "web_url" {
  value = "http://${aws_instance.web.public_ip}"
}