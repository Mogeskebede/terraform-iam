This README file explains the full workflow of the multi‑region Terraform deployment, the VPC design, the ALBs, the EC2 instances, the NAT gateways, and the Global Accelerator.

#  Detailed Deployment Process (What This Terraform Does)

This Terraform configuration builds a fully automated, production‑grade, multi‑region AWS architecture across us‑east‑1 and us‑east‑2.  
It provisions isolated VPCs, public and private subnets, NAT gateways, Application Load Balancers, private EC2 instances, and a Global Accelerator endpoint that provides global, low‑latency access to the application.

Below is a detailed breakdown of each component and how the system works end‑to‑end.

---

## 1. Multi‑Region VPC Creation
Terraform creates two independent VPCs, one in each region:

- VPC (us‑east‑1) – CIDR: `10.10.0.0/16`
- VPC (us‑east‑2) – CIDR: `10.20.0.0/16`

Each VPC is fully isolated and contains:

- Public subnets (for ALBs)
- Private subnets (for EC2 instances)
- Internet Gateway (IGW)
- NAT Gateway (for outbound EC2 traffic)
- Route tables for public and private networks

This ensures a clean, production‑ready network layout with proper separation of public and private resources.

---

## 2. Public Subnets (ALB Layer)
Each region gets two public subnets, one per Availability Zone.

These subnets:

- Automatically assign public IPs
- Route outbound traffic through the Internet Gateway
- Host the Application Load Balancers

The ALBs are the only publicly accessible entry points into each region.

---

## 3. Private Subnets (EC2 Layer)
Each region also gets two private subnets, one per AZ.

These subnets:

- Do not assign public IPs  
- Are not directly reachable from the internet  
- Route outbound traffic through the NAT Gateway

The EC2 instances hosting the application run exclusively in private subnets for security.

---

## 4. NAT Gateways
Each region includes a NAT Gateway placed in a public subnet.

Purpose:

- Allows private EC2 instances to access the internet (e.g., package installs)
- Prevents inbound connections from the internet
- Ensures secure outbound‑only connectivity

This is essential for user‑data scripts that install packages like `httpd`.

---

## 5. Application Load Balancers (Public Entry Points)
Each region deploys an Application Load Balancer in the public subnets.

The ALBs:

- Accept inbound HTTP traffic on port 80
- Forward traffic to EC2 instances in private subnets
- Perform health checks on `/health`
- Only route traffic to healthy instances

This ensures high availability and fault tolerance within each region.

---

## 6. EC2 Instances (Private Application Servers)
Each region launches a t3.micro EC2 instance inside a private subnet.

The instance:

- Runs Amazon Linux 2023
- Installs Apache (`httpd`)
- Serves the custom AWS Services Overview web application
- Exposes a `/health` endpoint for ALB health checks

Because the EC2 instances are private:

- They cannot be accessed directly from the internet  
- All traffic must flow through the ALB or Global Accelerator  

This is a best‑practice production security model.

---

## 7. Security Groups
Two security groups per region:

### ALB Security Group
- Allows inbound HTTP (80) from anywhere
- Allows outbound traffic to EC2 SG

### EC2 Security Group
- Allows inbound HTTP only from the ALB SG
- Allows outbound traffic to the NAT Gateway

This ensures zero direct public access to EC2.

---

## 8. Global Accelerator (Global Entry Point)
AWS Global Accelerator provides:

- A single, globally distributed Anycast IP endpoint
- Automatic routing to the closest healthy region
- Faster global performance than DNS‑based routing
- Automatic failover between regions

It attaches to:

- ALB (us‑east‑1)
- ALB (us‑east‑2)

If one region fails, GA instantly shifts traffic to the other.

---

## 9. Health Checks & Failover
Each ALB performs health checks on:

```
/health
```

If an EC2 instance becomes unhealthy:

- ALB removes it from rotation  
- GA detects the ALB as unhealthy  
- GA routes traffic to the other region  

This gives you automatic multi‑region failover.

---

## 10. End‑to‑End Traffic Flow
Here’s how a user request flows through the system:

1. User connects to Global Accelerator  
2. GA routes to the nearest healthy region  
3. Traffic hits the regional ALB  
4. ALB forwards to EC2 in private subnet  
5. EC2 serves the AWS Services Overview web app  
6. Response flows back through ALB → GA → user  

This architecture is:

- Highly available  
- Multi‑region  
- Secure  
- Scalable  
- Production‑ready  

---

## 11. Why This Architecture Matters
This setup gives you:

###  Multi‑Region High Availability
If one region fails, traffic automatically shifts to the other.

###  Private Compute Layer
EC2 instances are never exposed to the internet.

###  Public Load Balancing Layer
ALBs handle routing, health checks, and scaling.

###  Global Performance Optimization
Global Accelerator reduces latency for users worldwide.

###  Infrastructure as Code
Everything is reproducible, version‑controlled, and automated.
Architecture Diagram
The following is the architecture diagram that visually represents the entire multi‑region deployment.
It shows how traffic flows from AWS Global Accelerator to the regional ALBs, then into private EC2 instances running inside isolated VPCs with public and private subnets, NAT gateways, and proper routing.

![image](https://github.com/user-attachments/assets/f4cd5737-8e24-4eea-a8d6-d7db9d8494a0)
