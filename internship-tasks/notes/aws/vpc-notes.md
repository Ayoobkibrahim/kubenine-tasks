* Public Cloud Basics

1. What is Public Cloud?
A public cloud is a computing service offered by third-party providers over the public internet. Instead of owning your own hardware, you rent computing resources (like servers and storage) that share the same underlying physical infrastructure with other organizations or "tenants."


2. How AWS provides infrastructure?
AWS provides Infrastructure as a Service (IaaS). Rather than buying and maintaining physical data centers, you rent computing power, databases, and storage on a pay-as-you-go basis. AWS fully manages and secures the physical facilities and hardware on their end.


3. Shared Responsibility Model (High-level)
It is a framework that defines who secures what. AWS is responsible for the "Security OF the Cloud" (the physical hardware, facilities, and underlying network). The customer is responsible for the "Security IN the Cloud" (guest operating systems, application code, data, and firewall configurations).


* VPC Core Concepts

1. What is a VPC? (Virtual Private Cloud)
A VPC is a logically isolated section of the AWS cloud where you can launch resources in a custom-defined virtual network. It is essentially your own private, secure data center living inside the public cloud.


2. What is CIDR? (Classless Inter-Domain Routing)
CIDR is a standard method for allocating and defining IP addresses. In a VPC, a CIDR block (like 10.0.0.0/16) dictates the total range and number of IP addresses available for your network.


3. Why CIDR planning matters
CIDR planning is critical because you cannot easily change a VPC's primary IP range once it is created. Also, if you ever need to connect two different VPCs together (VPC Peering), their CIDR blocks cannot overlap. Poor planning leads to IP exhaustion or network collisions.


4. What is a Subnet?
A subnet is a smaller, subdivided chunk of your VPC's overall CIDR block. It allows you to group resources together based on their security and routing needs. Every subnet must be mapped to a single Availability Zone.


5. Public vs Private Subnet (Conceptual)
A public subnet has a direct route to the internet, making it ideal for internet-facing resources like load balancers or web servers. A private subnet does not have a direct route to the outside internet, keeping its resources (like backend databases) hidden and secure.


6. What is a Route Table?
A route table is a set of rules (routes) that acts as a traffic director for your network. It determines exactly where network traffic leaving your subnet or VPC is allowed to go.


7. What is an Internet Gateway (IGW)?
An Internet Gateway is a highly available AWS component attached to your VPC that enables communication between your VPC and the internet. Without an IGW, a public subnet cannot route traffic to or from the outside world.


8. Difference between Public and Private subnets
The core difference comes down to internet routing. A public subnet has a route table that directs internet-bound traffic to an Internet Gateway (IGW), allowing direct inbound and outbound internet access. A private subnet does not have a direct route to an IGW, meaning resources inside it cannot be reached directly from the outside world.


9. Why production workloads should live in private subnets
It is a fundamental security best practice to reduce your attack surface. By placing backend application servers and databases in a private subnet, you completely isolate them from direct internet exposure. Attackers cannot directly scan, ping, or SSH into these servers because there is no route connecting them to the outside internet. Only internet-facing resources, like Load Balancers or Bastion Hosts, should sit in the public subnet.


10. What is a NAT Gateway?
NAT stands for Network Address Translation. A NAT Gateway is a highly available, managed AWS service that sits in a public subnet. Its job is to allow resources in a private subnet to reach out to the internet (for things like software patches or API calls) without exposing those private resources to incoming internet connections.


11. How NAT allows outbound-only internet access
When a private server needs the internet, it sends its request to the NAT Gateway. The NAT Gateway masks the server's private IP address, replaces it with its own public IP address, and sends the request out through the Internet Gateway. When the response comes back, the NAT translates the IP back and forwards the data to the private server. Because the NAT only tracks outbound requests, external users on the internet cannot initiate a connection inward.


12. Route table differences between public and private subnets
Both route tables will contain a "local" route (e.g., 10.0.0.0/16 -> local) so everything inside the VPC can communicate with each other. The difference lies in how they handle the rest of the internet (0.0.0.0/0):
The Public Route Table directs 0.0.0.0/0 traffic to an Internet Gateway (igw-id).
The Private Route Table directs 0.0.0.0/0 traffic to a NAT Gateway (nat-id).


13. What is a Security Group?
A Security Group is a virtual firewall that controls inbound and outbound traffic at the instance level (e.g., an individual EC2 server or RDS database). You use it to define exactly which ports and IP ranges are allowed to communicate with that specific resource. By default, Security Groups deny all inbound traffic and allow all outbound traffic.


14. What is a Network ACL (NACL)?
A Network Access Control List (NACL) is an optional layer of security that acts as a virtual firewall at the subnet level. Instead of protecting a single server, it controls traffic entering and exiting an entire subnet. It acts as a broader, secondary line of defense outside of your Security Groups.


15. Difference between Stateful and Stateless filtering
This is a core difference in how firewalls handle connections:

* Stateful filtering (Security Groups): It remembers the connection. If a Security Group allows an incoming request (like a web request on port 80), the return response is automatically allowed back out, regardless of your outbound rules.

* Stateless filtering (NACLs): It treats every single packet independently. If a NACL allows incoming traffic, you must explicitly write a separate outbound rule to allow the return traffic back out, otherwise it will be blocked.


16. Inbound vs Outbound Rules
Inbound rules (ingress) dictate what external traffic is allowed to enter your resource or subnet (e.g., allowing users to reach your web server). Outbound rules (egress) dictate what traffic your resource or subnet is allowed to send out (e.g., allowing your server to reach out to the internet to download software updates).


17. How traffic flows through VPC layers
To reach a server from the internet, traffic follows a specific path: It enters the VPC through the Internet Gateway --> gets directed by the Route Table --> is evaluated by the subnet's NACL inbound rules --> enters the Subnet --> is evaluated by the instance's Security Group inbound rules --> finally reaches the EC2 Instance. The exact reverse path is taken on the way out.


18. Why security misconfiguration breaks applications
Applications rely on precise network ports to talk to each other (e.g., a frontend app needs port 5432 to talk to a PostgreSQL database). If a Security Group or NACL is too restrictive—like forgetting to open a port, allowing the wrong CIDR block, or forgetting a return rule on a stateless NACL—the network simply drops the packets. The application components are running, but they cannot "hear" each other, resulting in immediate connection timeouts and application downtime.


19. What is an Availability Zone (AZ)?
An Availability Zone (AZ) is one or more discrete, physical data centers within a specific AWS Region. They are built with redundant power, networking, and connectivity. If a Region (like "us-east-1") is a city, the AZs (like "us-east-1a", "us-east-1b") are separate, heavily fortified buildings located miles apart within that city.


20. Difference between Single-AZ vs Multi-AZ
Single-AZ means deploying your application or database in just one Availability Zone. If that specific data center experiences a massive failure, your application goes offline. Multi-AZ means deploying redundant copies of your resources across two or more Availability Zones simultaneously.


21. Why Multi-AZ improves availability
It removes the single point of failure. Because AZs are physically separated and isolated from each other's power grids and flood plains, a disaster in one AZ (like a fire, power outage, or severed fiber cable) will not affect the others. Your traffic automatically routes to the healthy AZ, keeping your application online.


22. Public and private subnets across multiple AZs
A single subnet cannot stretch across multiple AZs; it is permanently locked to just one. Therefore, to build a Multi-AZ architecture, you must create duplicate subnets. You will create a pair of subnets (one public, one private) in Availability Zone A, and another pair (one public, one private) in Availability Zone B. You then use an Elastic Load Balancer to distribute incoming traffic evenly across the subnets in both zones.


23. High-level cost vs reliability trade-offs
The trade-off is essentially paying for insurance. A Multi-AZ architecture gives you massive reliability and near-zero downtime, but it significantly increases your bill because you are paying to run duplicate servers, NAT Gateways, and databases. Additionally, AWS charges for data transfer between different Availability Zones. You have to balance the business cost of downtime against the monthly cost of redundant infrastructure.

