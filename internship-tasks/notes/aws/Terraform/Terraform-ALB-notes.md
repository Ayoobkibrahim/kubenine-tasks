*. ALB Architecture

1. What is an Application Load Balancer and how does it work? :  
An Application Load Balancer (ALB) operates at Layer 7 (the application layer) to route incoming web traffic across multiple targets based on the content of the request. It acts as a single point of contact for clients, distributing the load to ensure high availability and optimal application performance.

2. Listeners, target groups, and health checks :  
A listener checks for client connection requests on a specific port and protocol. A target group routes those requests to registered backend resources (like EC2 instances), while health checks continuously monitor these resources to ensure the ALB only sends traffic to servers that are functioning properly.

3. Why the ALB must be in public subnets and the instances can be in private subnets :  
The ALB requires a public IP address and an Internet Gateway route in a public subnet so that external internet clients can reach it. The backend EC2 instances are placed in private subnets to prevent direct internet exposure, relying on the ALB to securely proxy the public traffic to them.

4. How the ALB routes traffic to targets :  
When a listener receives a request, it evaluates its routing rules (such as URL path or hostname) to determine the correct target group. The ALB then uses a routing algorithm, typically round-robin, to distribute the request to a specific healthy target within that group using its private IP address.



*. ALB Module
1. terraform-aws-modules/alb/aws — what it provides : 
This official Terraform AWS module simplifies the creation and configuration of Application Load Balancers by bundling the necessary resources into a single package. It automatically provisions the ALB, target groups, listeners, and security group rules using best practices, saving you from writing verbose underlying resource blocks.

2. Key inputs: listeners, target groups, security groups, subnets :  
Listeners define the ports (e.g., 80) the ALB uses to accept traffic, while target groups define the backend destinations. You must also provide security groups to dictate allowed inbound traffic and subnets to determine which Availability Zones the ALB operates in.

3. Module registry :  
The module registry (hosted at registry.terraform.io) is the central repository where this pre-built infrastructure code is versioned and documented. It provides the exact syntax, input variables, and output values needed to implement the ALB module in your Terraform code.



*. Private Subnet EC2 Design
1. Why place instances in private subnets? :  
Placing instances in private subnets is a fundamental security practice that isolates your application layer from the public internet. It ensures the servers do not have public IP addresses, making it impossible for malicious actors to initiate direct external connections to your infrastructure.

2. How do private instances get internet access for package installation? :  
Private instances access the internet using a NAT (Network Address Translation) Gateway located in a public subnet. The NAT Gateway masks the private instances' IP addresses, allowing outbound traffic to reach the internet for updates while strictly blocking any unrequested inbound traffic.

3. How does the ALB reach private instances? :  
Even though the instances are isolated from the internet, the ALB and the instances share the same internal Virtual Private Cloud (VPC) network. The ALB communicates directly with the instances using their private IP addresses over the VPC's secure local route.



*. Security Group Design
1. ALB security group: accepts HTTP from the internet :  
The ALB acts as the public-facing front door to your application. Its security group is configured to allow inbound HTTP (port 80) or HTTPS (port 443) traffic from anywhere (0.0.0.0/0) so that end-users can access the website.

2. EC2 security group: accepts HTTP only from the ALB security group :  
To enforce strict security, the backend EC2 instances must reject direct internet traffic. Their security group is configured to only allow inbound traffic if the source is specifically the security group ID attached to the ALB.

3. This is the standard "chain" pattern :  
This chaining technique guarantees that traffic must flow through the load balancer to reach your application. It creates a secure perimeter where the outside world can only talk to the ALB, and the servers will only accept requests from the ALB.



*. Full Infrastructure Design
1. Planning a VPC layout for a specific architecture :  
A well-planned VPC separates resources into public and private tiers across multiple Availability Zones (AZs) to ensure high availability and security. Public subnets host edge routing resources like ALBs and NAT Gateways, while private subnets securely host the compute and database layers.

2. Making design decisions: how many AZs, CIDR allocation, NAT configuration :  
High availability requires deploying resources across at least two AZs to survive a data center outage. You must strategically allocate CIDR blocks to provide enough IP addresses for future scaling, and choose between a single NAT Gateway (cost-effective) or one NAT per AZ (maximum redundancy).

3. Wiring everything together: VPC → subnets → ALB → target group → EC2 :  
The architectural flow starts at the VPC level, using public subnets to host the ALB so it can receive external traffic. The ALB uses listeners to forward this traffic to a target group, which ultimately distributes the requests to securely isolated EC2 instances operating within the private subnets.