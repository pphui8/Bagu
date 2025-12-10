# AWS SAA course - Basics

## IAM service (Global service)
IAM = Identity and Access Management

Levels: user -> group -> role -> policy


User belongs to a group, group has policies attached to it. Multiple hierarchies possible.

inline policy = policy that is directly attached to a user, group or role. Not reusable.

### Security Credentials
1. password
2. MFA: Multi Factor Authentication (virtual or hardware)

### Access AWS
1. AWS Management Console (uses password and MFA)
2. AWS CLI (Access key)
3. AWS SDKs (Access key)

### IAM roles
- Used to give permissions to AWS services to interact with other AWS services on your behalf.  
"Give identity to an AWS service to interact with other AWS services"

### Security tools
1. IAM Credential Report: CSV file that lists all users and the status of their credentials.
2. IAM Access Advisor: Shows the services that a user has accessed and when was the last time they accessed a service.

### Summary
- Don`t use root account except for account setup.
- One physical user = one AWS account.
- Assign users to groups and assign permissions to groups.
- Create strong password policy.
- Use and enforce MFA.
- Create roles to delegate permissions to AWS services.
- Use Access Keys for programmatic access.

| Element | Description |
|---------|-------------|
| User    | Represents a person or service that interacts with AWS resources. |
| Group   | A collection of users that share the same permissions. |
| Role    | An identity with specific permissions that can be assumed by users or services. |
| Policy  | A document that defines permissions for users, groups, or roles. |
| Security | Password + MFA |
| Audit | IAM Credential Report + IAM Access Advisor |

## EC2 - Elastic Compute Cloud
- EC2: Virtual Servers in the Cloud.
- EBS: Elastic Block Store (Persistent storage for EC2 instances).
- ELB: Elastic Load Balancer (Distributes incoming traffic across multiple EC2 instances).
- ASG: Auto Scaling Group (Automatically adjusts the number of EC2 instances based on demand).

### Instance Types
> naming logic: TypeGeneration.size (m5.large)

| Type | Generation |
|------|------------|
| General Purpose | m, t, a |
| Compute Optimized | c |
| Memory Optimized | r, x |
| Storage Optimized | i, d, h |
| GPU Instances | p, g |


### Security Groups
- Virtual Firewall for your EC2 instances.  
It is a ```allow``` list, meaning you only define what traffic is allowed in or out. By default, all inbound traffic is blocked and all outbound traffic is allowed.

### EC2 Instance Connect
A browser-based SSH connection to your EC2 instances without needing to manage SSH keys.


### EC2 Pricing Models
- EC2 on demand: Pay for compute capacity by the hour or second with ```no long-term commitments``` (Full price).
- EC2 reserved: Make a one-time payment for a significant discount on the hourly charge for an instance (Plan ahead).
- EC2 savings plans: Commit to a consistent amount of usage (measured in $/hour) for a 1 or 3 year term in exchange for a lower rate.
- EC2 dedicated hosts: ```Physical servers``` with EC2 instance capacity fully dedicated to your use.
- EC2 spot: Bid for unused EC2 capacity at a discount (could be kicked out anytime if other uses).

### EC2 spot instances
Up to 90% discount compared to on-demand pricing. However, AWS can terminate your instance with a 2-minute warning if they need the capacity back.

Launch: spot request -> fulfilled (max price and number of instaces) -> instance launched -> instance terminated (if capacity needed back)

### Elastic IP
Static public IPv4 address designed for dynamic cloud computing.
- Associated with your AWS account. (instead of a specific instance)
- Can be remapped to another instance in the same region.
- Useful for instances that need a consistent public IP address.
- Charges apply if the Elastic IP is not associated with a running instance.

### Placement Groups
Logical grouping of instances within a single Availability Zone. Used to optimize network performance for certain workloads.

- Cluster: Packs instances close together inside an AZ. Low latency, high throughput. But if the hardware fails, all instances fail.
- Spread: Distributes instances across distinct underlying hardware. Reduces correlated failures. Max 7 instances per AZ. But higher latency.
- Partition: Divides each AZ into logical segments called partitions. Each partition has its own set of racks. Used for large distributed and replicated workloads like HDFS, HBase, Cassandra.

### Elastic Network Interface (ENI)
A virtual network interface that can be attached to an instance in a VPC (Virtual Private Cloud), multiple ENIs can be attached to an instance.

### EC2 Hibernate
Saves the contents of the instance's RAM to the EBS root volume. WHen the instance is started again, the RAM contents are restored, and the instance resumes from where it left off.

### EBS Storage Section
EBS = Elastic Block Store: Persistent block storage for EC2 instances.

- Can only be attached to one EC2 instance at a time (in the same AZ).

#### EBS Snapshot
- Point-in-time backup of an EBS volume. (Cross AZ)


### AMI - Amazon Machine Image
A template that contains the software configuration (operating system, application server, and applications) required to launch an EC2 instance.

- Create: Launch instance -> customize -> create image -> AMI created

### EC2 Instance Store
High-performance temporary storage that is physically attached to the host computer. Data is lost when the instance is stopped or terminated. (ephemeral storage)

### Volume Types
- General Purpose SSD (gp2, gp3): **Balanced** price and performance for a wide variety of workloads.
- Provisioned IOPS SSD (io1, io2): **High-performance** SSD designed for I/O-intensive applications.
- Throughput Optimized HDD (st1): **Low-cost HDD** designed for frequently accessed, throughput-intensive workloads.
- Cold HDD (sc1): **Lowest cost** HDD designed for less frequently accessed data.

### Multiple Attach (io2 only)
Allows a single io2 volume to be attached to multiple EC2 instances simultaneously. Useful for clustered applications that require shared storage.

### EBS Encryption
EBS volumes can be encrypted to protect data at rest. Encryption is handled by AWS Key Management Service (KMS).


### Elastic File System (EFS) - auto scaling
A fully managed NFS (Network File System) file system that can be mounted on multiple EC2 instances. Provides scalable storage that grows and shrinks automatically as files are added or removed.

EFS-IA (Infrequent Access): Lower cost storage class for files that are not accessed frequently.


### EBS vs EFS vs S3
| Feature         | EBS                          | EFS                          | S3                           |
|-----------------|------------------------------|------------------------------|------------------------------|
| Type            | Block Storage                | File Storage                 | Object Storage               |
| Use Case        | Single EC2 instance          | Multiple EC2 instances       | Static website
| Scalability     | Fixed size                   | Automatically scales         | Virtually unlimited          |
| Performance     | High IOPS                    | High throughput              | Variable                     |
| AZ Scope       | Single AZ                    | Multiple AZs                 | Global                       |


## Scalability and High Availability
- Scalability: The ability to handle increased load by adding resources.
- High Availability: The ability to remain operational and accessible even in the event of failures.

### Load Balancer Types
- Gateway Load Balancer (GLB): Operates at the network layer (Layer 3). Ideal for deploying, scaling, and managing virtual appliances such as firewalls, intrusion detection and prevention systems, and deep packet inspection systems.
- Application Load Balancer (ALB): Operates at the application layer (Layer 7). Ideal for HTTP and HTTPS traffic. Supports advanced routing features.
- Network Load Balancer (NLB): Operates at the transport layer (Layer 4). Ideal for TCP, UDP, and TLS traffic. Can handle millions of requests per second with low latency.
- Classic Load Balancer (CLB): Operates at both the application and transport layers. Legacy option, generally replaced by ALB and NLB.

Elastic Load Balancer: Distributes incoming application traffic across multiple targets, such as EC2 instances, in multiple Availability Zones.
- Health Checks: Monitors the health of registered targets and routes traffic only to healthy instances.

### Classic load balancer
- Supports both Layer 4 (TCP) and Layer 7 (HTTP/HTTPS) load balancing.

Rond-robin strategy: evenly distributes incoming requests.

### Application Load Balancer
- Operates at Layer 7 (Application Layer).
- Support http/https and websocket protocols.
- Fit for microservices and container-based architectures.

Host-based routing: Routes traffic based on the host field in the HTTP header.
Path-based routing: Routes traffic based on the URL path of the request.
- domain routing (www.xxx.com)
- URL routing (/app1, /app2)
- query string routing (?type=xxx)

WHat`s happening behind the scenes:

Client <-> ALB <-> Target Group <-> EC2 instances

Application server dose not see the client IP, it responds to ALB with http head of "X-Forwarded-For" containing the client IP.

