# Project Bedrock - Architecture Diagram

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                                    AWS Cloud                                         │
│                                  Region: us-east-1                                   │
│                                                                                      │
│  ┌────────────────────────────────────────────────────────────────────────────────┐ │
│  │                          VPC (10.0.0.0/16)                                     │ │
│  │                                                                                 │ │
│  │  ┌─────────────────────────────────┐   ┌─────────────────────────────────┐   │ │
│  │  │   Availability Zone A           │   │   Availability Zone B           │   │ │
│  │  │                                 │   │                                 │   │ │
│  │  │  ┌──────────────────────────┐  │   │  ┌──────────────────────────┐  │   │ │
│  │  │  │  Public Subnet           │  │   │  │  Public Subnet           │  │   │ │
│  │  │  │  (10.0.1.0/24)           │  │   │  │  (10.0.2.0/24)           │  │   │ │
│  │  │  │                          │  │   │  │                          │  │   │ │
│  │  │  │  ┌─────────────────┐    │  │   │  │  ┌─────────────────┐    │  │   │ │
│  │  │  │  │  NAT Gateway    │────┼──┼───┼──┼──│  NAT Gateway    │    │  │   │ │
│  │  │  │  │   (EIP attached)│    │  │   │  │  │   (EIP attached)│    │  │   │ │
│  │  │  │  └─────────────────┘    │  │   │  │  └─────────────────┘    │  │   │ │
│  │  │  └──────────────────────────┘  │   │  └──────────────────────────┘  │   │ │
│  │  │            │                    │   │            │                    │   │ │
│  │  │            │                    │   │            │                    │   │ │
│  │  │  ┌─────────▼──────────────┐   │   │  ┌─────────▼──────────────┐   │   │ │
│  │  │  │  Private Subnet         │   │   │  │  Private Subnet         │   │   │ │
│  │  │  │  (10.0.11.0/24)         │   │   │  │  (10.0.12.0/24)         │   │   │ │
│  │  │  │                          │   │   │  │                          │   │   │ │
│  │  │  │  ┌─────────────────┐    │   │   │  │  ┌─────────────────┐    │   │   │ │
│  │  │  │  │  EKS Worker     │    │   │   │  │  │  EKS Worker     │    │   │   │ │
│  │  │  │  │  Node 1         │    │   │   │  │  │  Node 2         │    │   │   │ │
│  │  │  │  │  (t3.small)     │    │   │   │  │  │  (t3.small)     │    │   │   │ │
│  │  │  │  │                 │    │   │   │  │  │                 │    │   │   │ │
│  │  │  │  │  ┌───────────┐ │    │   │   │  │  │  ┌───────────┐ │    │   │   │ │
│  │  │  │  │  │ UI Pod    │ │    │   │   │  │  │  │ Cart Pod  │ │    │   │   │ │
│  │  │  │  │  └───────────┘ │    │   │   │  │  │  └───────────┘ │    │   │   │ │
│  │  │  │  │  ┌───────────┐ │    │   │   │  │  │  ┌───────────┐ │    │   │   │ │
│  │  │  │  │  │Catalog Pod│ │    │   │   │  │  │  │Checkout   │ │    │   │   │ │
│  │  │  │  │  └───────────┘ │    │   │   │  │  │  │ Pod       │ │    │   │   │ │
│  │  │  │  └─────────────────┘    │   │   │  │  └───────────┘ │    │   │   │ │
│  │  │  │                          │   │   │  │  ┌─────────────────┐    │   │   │ │
│  │  │  │                          │   │   │  │  │  EKS Worker     │    │   │   │ │
│  │  │  │                          │   │   │  │  │  Node 3         │    │   │   │ │
│  │  │  │                          │   │   │  │  │  (t3.small)     │    │   │   │ │
│  │  │  │                          │   │   │  │  │                 │    │   │   │ │
│  │  │  │                          │   │   │  │  │  ┌───────────┐ │    │   │   │ │
│  │  │  │                          │   │   │  │  │  │Orders Pod │ │    │   │   │ │
│  │  │  │                          │   │   │  │  │  └───────────┘ │    │   │   │ │
│  │  │  │                          │   │   │  │  └─────────────────┘    │   │   │ │
│  │  │  └──────────────────────────┘   │   │  └──────────────────────────┘   │   │ │
│  │  └─────────────────────────────────┘   └─────────────────────────────────┘   │ │
│  │                                                                                 │ │
│  └────────────────────────────────────────────────────────────────────────────────┘ │
│                                                                                      │
│  ┌────────────────────────────────────────────────────────────────────────────────┐ │
│  │                         EKS Control Plane (Managed by AWS)                     │ │
│  │                                                                                 │ │
│  │   ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │ │
│  │   │ API Server   │  │  Scheduler   │  │  Controller  │  │ etcd         │    │ │
│  │   │              │  │              │  │  Manager     │  │ (cluster     │    │ │
│  │   │              │  │              │  │              │  │  state)      │    │ │
│  │   └──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘    │ │
│  │                                                                                 │ │
│  │   Cluster: project-bedrock-cluster (v1.34)                                    │ │
│  └────────────────────────────────────────────────────────────────────────────────┘ │
│                                                                                      │
│  ┌────────────────────────────────────────────────────────────────────────────────┐ │
│  │                              Data Layer (RDS)                                  │ │
│  │                                                                                 │ │
│  │   ┌─────────────────────────────────────┐   ┌─────────────────────────────┐  │ │
│  │   │   MySQL Database                    │   │   PostgreSQL Database       │  │ │
│  │   │   Instance: bedrock-catalog-mysql   │   │   Instance:                 │  │ │
│  │   │   Engine: MySQL 8.0                 │   │   bedrock-orders-postgres   │  │ │
│  │   │   Class: db.t3.micro               │   │   Engine: PostgreSQL 15     │  │ │
│  │   │                                     │   │   Class: db.t3.micro        │  │ │
│  │   │   ┌────────────────────────────┐   │   │                             │  │ │
│  │   │   │  Catalog Service Data      │   │   │   ┌────────────────────┐   │  │ │
│  │   │   │  - Products                │   │   │   │ Orders Service Data│   │  │ │
│  │   │   │  - Categories              │   │   │   │ - Customer Orders  │   │  │ │
│  │   │   │  - Inventory               │   │   │   │ - Order History    │   │  │ │
│  │   │   └────────────────────────────┘   │   │   └────────────────────┘   │  │ │
│  │   │                                     │   │                             │  │ │
│  │   │   Endpoint:                         │   │   Endpoint:                 │  │ │
│  │   │   bedrock-catalog-mysql             │   │   bedrock-orders-postgres   │  │ │
│  │   │   .c2d062uwkhs2.us-east-1          │   │   .c2d062uwkhs2.us-east-1  │  │ │
│  │   │   .rds.amazonaws.com:3306          │   │   .rds.amazonaws.com:5432  │  │ │
│  │   └─────────────────────────────────────┘   └─────────────────────────────┘  │ │
│  └────────────────────────────────────────────────────────────────────────────────┘ │
│                                                                                      │
│  ┌────────────────────────────────────────────────────────────────────────────────┐ │
│  │                        Serverless Layer (S3 + Lambda)                          │ │
│  │                                                                                 │ │
│  │   ┌──────────────────────────────────────────────────────────────────────┐    │ │
│  │   │                     S3 Bucket: bedrock-assets-alt-soe-025-0275       │    │ │
│  │   │                                                                       │    │ │
│  │   │   Upload Asset (Image/File)                                          │    │ │
│  │   │          │                                                            │    │ │
│  │   │          ▼                                                            │    │ │
│  │   │   ┌──────────────────────────────────────────────────────┐          │    │ │
│  │   │   │  S3 Event Notification (on Object Created)           │          │    │ │
│  │   │   └──────────────────┬───────────────────────────────────┘          │    │ │
│  │   │                      │                                               │    │ │
│  │   │                      │ Triggers                                      │    │ │
│  │   │                      ▼                                               │    │ │
│  │   │   ┌────────────────────────────────────────────────────────────┐   │    │ │
│  │   │   │  Lambda Function: bedrock-asset-processor               │   │    │ │
│  │   │   │  Runtime: Python 3.11                                   │   │    │ │
│  │   │   │  Memory: 256 MB                                          │   │    │ │
│  │   │   │  Timeout: 30 seconds                                     │   │    │ │
│  │   │   │                                                           │   │    │ │
│  │   │   │  Processing Logic:                                        │   │    │ │
│  │   │   │  1. Receive S3 event                                     │   │    │ │
│  │   │   │  2. Extract object key                                   │   │    │ │
│  │   │   │  3. Process asset (resize, validate, etc.)              │   │    │ │
│  │   │   │  4. Store metadata                                       │   │    │ │
│  │   │   │  5. Log to CloudWatch                                    │   │    │ │
│  │   │   └────────────────────────────────────────────────────────────┘   │    │ │
│  │   │                      │                                               │    │ │
│  │   │                      ▼                                               │    │ │
│  │   │   ┌─────────────────────────────────────────────────────┐          │    │ │
│  │   │   │  CloudWatch Logs: /aws/lambda/bedrock-asset-processor │          │    │ │
│  │   │   └─────────────────────────────────────────────────────┘          │    │ │
│  │   └──────────────────────────────────────────────────────────────────────┘    │ │
│  └────────────────────────────────────────────────────────────────────────────────┘ │
│                                                                                      │
│  ┌────────────────────────────────────────────────────────────────────────────────┐ │
│  │                         Observability Layer (CloudWatch)                       │ │
│  │                                                                                 │ │
│  │   ┌───────────────────────────────────────────────────────────────────────┐   │ │
│  │   │  CloudWatch Log Groups                                                │   │ │
│  │   │                                                                        │   │ │
│  │   │  - /aws/eks/project-bedrock-cluster/cluster (Control Plane Logs)    │   │ │
│  │   │  - /aws/lambda/bedrock-asset-processor (Lambda Logs)                │   │ │
│  │   │                                                                        │   │ │
│  │   │  CloudWatch Metrics                                                   │   │ │
│  │   │  - EKS Cluster Metrics (CPU, Memory, Network)                        │   │ │
│  │   │  - Node Metrics (Instance Health, Disk I/O)                          │   │ │
│  │   │  - Lambda Metrics (Invocations, Duration, Errors)                    │   │ │
│  │   └───────────────────────────────────────────────────────────────────────┘   │ │
│  └────────────────────────────────────────────────────────────────────────────────┘ │
│                                                                                      │
│  ┌────────────────────────────────────────────────────────────────────────────────┐ │
│  │                          Security & Access Control                             │ │
│  │                                                                                 │ │
│  │   ┌──────────────────────────────────┐   ┌────────────────────────────────┐  │ │
│  │   │  IAM - Identity & Access         │   │  Kubernetes RBAC               │  │ │
│  │   │                                  │   │                                │  │ │
│  │   │  - EKS Cluster Role              │   │  - aws-auth ConfigMap         │  │ │
│  │   │  - Node Group Role               │   │  - ClusterRole Bindings       │  │ │
│  │   │  - Lambda Execution Role         │   │  - Role Bindings              │  │ │
│  │   │  - Developer User (View-Only)    │   │  - Namespace: retail-app      │  │ │
│  │   │  - IRSA (Pod-level IAM)         │   │                                │  │ │
│  │   └──────────────────────────────────┘   └────────────────────────────────┘  │ │
│  │                                                                                 │ │
│  │   ┌────────────────────────────────────────────────────────────────────────┐  │ │
│  │   │  Security Groups                                                       │  │ │
│  │   │  - EKS Cluster SG (API Server access)                                 │  │ │
│  │   │  - Node Group SG (Worker-to-worker communication)                     │  │ │
│  │   │  - RDS SG (Database access from EKS only)                            │  │ │
│  │   └────────────────────────────────────────────────────────────────────────┘  │ │
│  └────────────────────────────────────────────────────────────────────────────────┘ │
│                                                                                      │
└──────────────────────────────────────────────────────────────────────────────────────┘
```

## Application Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                       Retail Store Microservices Architecture                    │
│                                                                                  │
│                                                                                  │
│  User/Browser                                                                    │
│       │                                                                           │
│       ▼                                                                           │
│  ┌────────────────────────────────────────────────────────────────────────┐     │
│  │                       UI Service (Frontend)                            │     │
│  │                       - React/Next.js Application                       │     │
│  │                       - Serves Web Interface                            │     │
│  │                       - ClusterIP Service: ui:80                       │     │
│  └────────────────────────────────────────────────────────────────────────┘     │
│       │                                                                           │
│       │ API Calls                                                                │
│       ▼                                                                           │
│  ┌──────────────────────────┬─────────────────────────┬──────────────────────┐ │
│  │                          │                         │                      │ │
│  ▼                          ▼                         ▼                      ▼ │
│  ┌──────────────────┐  ┌────────────────┐  ┌─────────────────┐  ┌──────────────┐
│  │ Catalog Service  │  │  Cart Service  │  │ Checkout Service│  │Orders Service│
│  │                  │  │                │  │                 │  │              │
│  │ - Product Info   │  │ - Shopping Cart│  │ - Payment       │  │ - Order Mgmt │
│  │ - Search         │  │ - Add/Remove   │  │ - Validation    │  │ - History    │
│  │ - Categories     │  │ - Persistence  │  │                 │  │              │
│  │                  │  │                │  │                 │  │              │
│  │ ClusterIP:       │  │ ClusterIP:     │  │ ClusterIP:      │  │ClusterIP:    │
│  │ catalog:80       │  │ cart:80        │  │ checkout:80     │  │orders:80     │
│  └────────┬─────────┘  └────────────────┘  └─────────────────┘  └──────┬───────┘
│           │                                                              │        │
│           │ Database Connection                                          │        │
│           ▼                                                              ▼        │
│  ┌──────────────────────────────┐                           ┌────────────────────┐
│  │  MySQL Database              │                           │PostgreSQL Database │
│  │  bedrock-catalog-mysql       │                           │bedrock-orders-     │
│  │                              │                           │postgres            │
│  │  - Products Table            │                           │                    │
│  │  - Categories Table          │                           │ - Orders Table     │
│  │  - Inventory Table           │                           │ - Order Items Table│
│  └──────────────────────────────┘                           └────────────────────┘
│                                                                                  │
└──────────────────────────────────────────────────────────────────────────────────┘
```

## Traffic Flow

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                              Traffic Flow Diagram                             │
│                                                                               │
│  Internet                                                                     │
│     │                                                                          │
│     ▼                                                                          │
│  ┌────────────────────┐                                                       │
│  │  Internet Gateway  │                                                       │
│  └─────────┬──────────┘                                                       │
│            │                                                                   │
│            │ (Future: ALB/Ingress would be here)                             │
│            │                                                                   │
│            ▼                                                                   │
│  ┌────────────────────────────────────────────────────────┐                  │
│  │              Public Subnets (NAT Gateways)             │                  │
│  └─────────────────────┬──────────────────────────────────┘                  │
│                        │                                                       │
│                        │ Outbound Internet Access                             │
│                        ▼                                                       │
│  ┌─────────────────────────────────────────────────────────────────────┐     │
│  │                     Private Subnets (EKS Nodes)                     │     │
│  │                                                                      │     │
│  │   ┌────────────┐   ┌────────────┐   ┌────────────┐                │     │
│  │   │   Pod      │◄──│   Pod      │◄──│   Pod      │                │     │
│  │   │ (Service A)│   │ (Service B)│   │ (Service C)│                │     │
│  │   └────────────┘   └────────────┘   └────────────┘                │     │
│  │                                                                      │     │
│  │   Internal Communication via ClusterIP Services                     │     │
│  │   - DNS Resolution via CoreDNS                                      │     │
│  │   - Service Discovery                                               │     │
│  │   - Load Balancing                                                  │     │
│  └─────────────────────────────────────────────────────────────────────┘     │
│                        │                                                       │
│                        │ Database Connections (TCP 3306, 5432)               │
│                        ▼                                                       │
│  ┌─────────────────────────────────────────────────────────────────────┐     │
│  │                    RDS Subnet Group                                 │     │
│  │              (MySQL & PostgreSQL Instances)                         │     │
│  └─────────────────────────────────────────────────────────────────────┘     │
│                                                                               │
└───────────────────────────────────────────────────────────────────────────────┘
```

## S3-Lambda Event Flow (Asset Processing)

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                       S3-Lambda Asset Processing Flow                         │
│                                                                               │
│  Step 1: Upload                                                              │
│  ┌────────────┐                                                              │
│  │   User/App │                                                              │
│  └──────┬─────┘                                                              │
│         │                                                                     │
│         │ PUT /products/image.jpg                                            │
│         ▼                                                                     │
│  ┌────────────────────────────────────────────────┐                         │
│  │  S3 Bucket: bedrock-assets-alt-soe-025-0275   │                         │
│  │                                                 │                         │
│  │  /products/                                    │                         │
│  │     ├── product1.jpg                           │                         │
│  │     ├── product2.jpg                           │                         │
│  │     └── image.jpg  ◄─── NEW FILE               │                         │
│  │                                                 │                         │
│  │  /images/                                      │                         │
│  │  /documents/                                   │                         │
│  └─────────────────────┬───────────────────────────┘                         │
│                        │                                                      │
│  Step 2: Event Trigger │                                                     │
│                        │                                                      │
│                        │ S3 Event Notification                               │
│                        │ (ObjectCreated:Put)                                 │
│                        ▼                                                      │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │  Lambda Function: bedrock-asset-processor                            │   │
│  │                                                                       │   │
│  │  Event Payload:                                                      │   │
│  │  {                                                                   │   │
│  │    "Records": [{                                                     │   │
│  │      "s3": {                                                         │   │
│  │        "bucket": {"name": "bedrock-assets-alt-soe-025-0275"},      │   │
│  │        "object": {"key": "products/image.jpg", "size": 12345}      │   │
│  │      }                                                               │   │
│  │    }]                                                                │   │
│  │  }                                                                   │   │
│  └───────────────────────────┬──────────────────────────────────────────┘   │
│                              │                                               │
│  Step 3: Processing          │                                               │
│                              ▼                                               │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │  Lambda Execution:                                                   │   │
│  │                                                                       │   │
│  │  1. Extract bucket name and object key                              │   │
│  │  2. Validate file type and size                                     │   │
│  │  3. Generate thumbnail (if image)                                   │   │
│  │  4. Extract metadata                                                │   │
│  │  5. Update database (optional)                                      │   │
│  │  6. Send notification (optional)                                    │   │
│  └───────────────────────────┬──────────────────────────────────────────┘   │
│                              │                                               │
│  Step 4: Logging             ▼                                               │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │  CloudWatch Logs: /aws/lambda/bedrock-asset-processor               │   │
│  │                                                                       │   │
│  │  2026-02-03T10:00:00.000Z  START RequestId: abc-123                │   │
│  │  2026-02-03T10:00:00.100Z  Processing: products/image.jpg          │   │
│  │  2026-02-03T10:00:00.500Z  File validated: 12345 bytes             │   │
│  │  2026-02-03T10:00:01.000Z  Thumbnail generated                      │   │
│  │  2026-02-03T10:00:01.200Z  END RequestId: abc-123                  │   │
│  │  2026-02-03T10:00:01.200Z  REPORT Duration: 1200ms Memory: 256MB   │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                                                               │
│  Step 5: Result (Optional)                                                   │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │  Processed file stored back in S3 (optional):                       │   │
│  │  /products/thumbnails/image-thumb.jpg                               │   │
│  │                                                                       │   │
│  │  Or metadata stored in DynamoDB/RDS (optional)                      │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                                                               │
└───────────────────────────────────────────────────────────────────────────────┘
```

## Network Flow Summary

**Inbound Traffic:**
- Internet → Internet Gateway → Public Subnets → (Future: ALB)
- kubectl/API access → EKS API Endpoint (HTTPS)

**Outbound Traffic:**
- Private Subnets → NAT Gateway → Internet Gateway → Internet
- Used for: ECR image pulls, AWS API calls, package updates

**Internal Traffic:**
- Pod ↔ Pod: Direct communication via CNI
- Pod → Service: ClusterIP load balancing
- Pod → RDS: Security group controlled access
- Pod → S3/Lambda: IAM role-based access via IRSA

**Security Boundaries:**
- Public subnets: NAT Gateways only
- Private subnets: EKS nodes, application workloads
- RDS subnet group: Database instances (private)
- Security groups control all network traffic
- Network ACLs provide subnet-level filtering

## Deployment Model

```
Developer Workflow:
Code Push → GitHub → (Future: GitHub Actions CI/CD) → EKS Deployment

Current Deployment:
Helm Charts → kubectl apply → EKS Cluster → Pods Running
```

---

## Key Architecture Decisions

1. **Multi-AZ Deployment**: High availability across 2 availability zones
2. **Private Subnets**: EKS nodes isolated from direct internet access
3. **NAT Gateway Redundancy**: Separate NAT gateway per AZ for fault tolerance
4. **Managed Services**: Using EKS control plane, RDS, Lambda for reduced operational overhead
5. **Security Layers**: Multiple security controls (IAM, RBAC, Security Groups, Network ACLs)
6. **Microservices Pattern**: Independent services with their own databases
7. **Event-Driven Processing**: S3 events trigger Lambda for async processing
8. **Observability**: Centralized logging via CloudWatch

---

**Project**: Project Bedrock  
**Student ID**: ALT/SOE/025/0275  
**Cluster**: project-bedrock-cluster  
**Region**: us-east-1  
**Deployment Date**: February 3, 2026
