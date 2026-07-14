# Production-Ready AWS Three-Tier Architecture Blueprint

A DevOps-focused infrastructure planning blueprint for deploying a highly available, secure, and resilient three-tier web application on AWS using modern Infrastructure as Code (IaC) and Automation best practices.

## 📌 Architecture Overview

This project provides the structural architecture blueprint for a classic decoupled web application split into three distinct layers (Web Frontend, Backend Application, and Data/Caching) spanning multiple Availability Zones (AZs) for maximum fault tolerance.

```
                         [ Internet ]
                              │
                              ▼
                        [ Route 53 ]
                              │
                              ▼
                      [ Internet Gateway ]
                              │
                              ▼
                  [ Application Load Balancer ]
                               │
                               ▼
                   [ Web Tier Application ]
                 (Public Subnets - AZ 1 & AZ 2)
                               │
               ┌───────────────┴───────────────┐
               ▼                               ▼
     [ Backend Application ]         [ Backend Application ]
   (Private App Subnet - AZ 1)     (Private App Subnet - AZ 2)
         │               │               │               │
         ▼               ▼               ▼               ▼
   [ ElastiCache ]  [ RDS Primary ]  [ ElastiCache ]  [ RDS Standby ]
    (Private Data)   (Private Data)   (Private Data)   (Private Data)
```

---

## 🏗️ Core Infrastructure Components

### 1. Networking Tier (Isolation & Routing)

- **1 Virtual Private Cloud (VPC):** Custom IP addressing scheme (e.g., `10.0.0.0/16`) to provide a secure network boundary.
- **6 Subnets across 2 Availability Zones (Multi-AZ):**
  - **Public Subnets (x2):** Houses the public-facing Web Tier applications, the Application Load Balancer (ALB), and the NAT Gateways. Direct routing to the Internet Gateway.
  - **Private App Subnets (x2):** Hosts the backend EC2 application instances. Completely isolated from incoming public internet traffic. Connected to the NAT Gateways in the public subnets for controlled outbound internet access (e.g., pulling patches).
  - **Private Data Subnets (x2):** Dedicated exclusively for the database engine and caching layers. Zero external routing.
- **Network Address Translation (NAT) Gateways:** Deployed inside the public subnets and explicitly tied to the private app subnets' route tables, allowing backend applications to fetch software updates securely.

### 2. Presentation & Web Tier (Edge & Front Facing)

- **Route 53:** Global Domain Name System (DNS) providing highly available domain routing and health checking.
- **Application Load Balancer (ALB):** Evaluates incoming traffic headers and dynamically routes user HTTP/HTTPS requests evenly across healthy nodes in the public Web Tier.
- **Web Tier Application:** EC2 instances or containers running in the **public subnets** that handle incoming web presentation traffic, serving as the interface that passes requests down to the backend.

### 3. Application Tier (Logic / Core Backend)

- **Backend Application Tier:** Deployed inside the **private subnets** to process business logic safely out of the public domain. Communicates upstream with the public Web Tier.
- **AWS Auto Scaling Group (ASG):** Automatically provisions, heals, and scales these private backend compute instances horizontally based on resource demand.

### 4. Data & Caching Tier (Persistence & Performance)

- **Amazon RDS (Multi-AZ Deployment):** Fully managed Relational Database Service running **PostgreSQL** or **MySQL** located strictly in the private data subnets. Synchronous replication keeps a standby replica ready in the secondary AZ for failover.
- **Amazon ElastiCache for Redis:** A high-performance, in-memory caching tier deployed alongside the database in the private data subnets. Used by the backend application to offload frequent database queries, lower latency, and manage application state.

---

## 🔒 Security Architecture & Group Configuration

Security is configured natively using Least-Privilege Access Controls via AWS Security Groups (Stateful Firewalls):

| Tier            | Component               | Inbound Source                 | Allowed Ports                      | Purpose                                           |
| :-------------- | :---------------------- | :----------------------------- | :--------------------------------- | :------------------------------------------------ |
| **Edge**        | ALB Security Group      | `0.0.0.0/0` (Anywhere)         | `80` (HTTP), `443` (HTTPS)         | Public web entry point                            |
| **Web**         | Web Tier Security Group | `ALB Security Group Only`      | `80` / `443`                       | Restricts presentation layer to ALB traffic       |
| **Application** | Backend Security Group  | `Web Tier Security Group Only` | `8080` or `5000` (App Port)        | Restricts backend layer to web tier requests      |
| **Caching**     | Redis Security Group    | `Backend Security Group Only`  | `6379` (Redis Default)             | Restricts cache access exclusively to the backend |
| **Data**        | RDS Security Group      | `Backend Security Group Only`  | `5432` (Postgres) / `3306` (MySQL) | Isolates database layers completely               |

---

## 🚀 DevOps Implementation Roadmap

To transition this blueprint from architecture design to standard production code, execute the following three stages:

### Stage 1: Infrastructure as Code (IaC) with Terraform

- Declare your providers and maintain local state tracking (remote state storage/locking with S3 and DynamoDB can be phased in during a future migration sprint).
- Modularize components: `modules/vpc`, `modules/compute`, `modules/caching`, `modules/database`.
- Prevent resource hardcoding; use `variables.tf` and `terraform.tfvars` files to switch environments seamlessly (Dev, Staging, Prod).

### Stage 2: Configuration Management via Ansible

- Write dynamic playbooks to target instances launched inside the private subnets via a bastion host or SSM Session Manager.
- Set up node dependencies, patch operational systems, configure internal security parameters, and bootstrap environment variables for both the Web and Backend applications.

### Stage 3: CI/CD Pipeline Integration (GitHub Actions / GitLab CI)

1. **Infra Lint Phase:** Validate and run `terraform fmt -check` and `trivy` security scans on commit.
2. **Infrastructure Rollout:** On merge to main, initiate automatic execution of `terraform apply --auto-approve`.
3. **Application Deployment:** Build your application logic, pull down secure environmental secrets from **AWS Secrets Manager**, and roll out builds zero-downtime onto the target groups.

---

## 🛠️ Verification & Testing Strategy

- **Cache Latency Validation:** Run load tests against backend APIs to verify successful read-hits from the ElastiCache Redis clusters rather than hitting the RDS instance every time.
- **Fault-Tolerance Verification:** Manually terminate one EC2 instance to verify the ASG spins up a replacement instantly.
- **Database Failover Check:** Force a reboot with failover on Amazon RDS to ensure the application automatically reconnects to the newly promoted standby instance in under 60 seconds.
