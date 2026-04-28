*. Terraform Modules

1. What is a Terraform module and why do they exist? : 
A Terraform module is a self-contained collection of infrastructure resources configured to work together. They exist to make code reusable, organized, and easier to share across teams without rewriting the same code from scratch.

2. Public modules vs. private modules : 
Public modules are open-source, community-vetted blueprints available to anyone, usually via the Terraform Registry. Private modules are restricted to your organization to enforce internal security and architectural standards.

3. The Terraform Registry : 
This is the official, centralized repository where you can search for, read documentation on, and download both Terraform modules and providers.

4. Module inputs, outputs, and versioning : 
Inputs (variables) allow you to pass custom values to configure the module, while outputs return specific data created by the module for other resources to use. Versioning ensures your code relies on a specific, stable release of the module to prevent unexpected breaking changes when the module is updated.

5. How a module call works : 
A module call uses the module block and a source argument to tell Terraform exactly where to fetch the underlying code (locally or from a registry) and execute it within your configuration.



*. The VPC Module

1. terraform-aws-modules/vpc/aws : 
This is an official, highly popular public module that automatically provisions a complete, best-practice Virtual Private Cloud (VPC) network architecture in AWS with very little code.

2. Key inputs : 
You use inputs to define the VPC's overall network size (cidr), the availability zones to span (azs), the specific IP blocks for your tiers (public_subnets, private_subnets), and whether to allow private resources to access the internet (enable_nat_gateway).

3. Behind the scenes resources : 
Instead of writing dozens of resource blocks manually, this module automatically generates the underlying Subnets, Route Tables, Internet Gateways (IGW), NAT Gateways, and Elastic IPs (EIPs) needed for a functioning network.

4. Reading module documentation : 
You read Registry documentation by checking the "Readme" for basic examples, the "Inputs" tab to see which variables are required versus optional, and the "Outputs" tab to know what resulting data you can reference later.



*. Multi-AZ Networking

1. Why 3 AZs? : 
Spreading resources across three Availability Zones ensures high availability and fault tolerance in production environments. It is also often a strict requirement for deploying highly available AWS services, like Application Load Balancers.

2. CIDR planning for 6 subnets : 
This involves taking a large /16 network (65,536 IPs) and carving out smaller, non-overlapping subnet blocks (like /24s) distributed evenly across three AZs to neatly separate your public and private workloads.

3. Public vs. private subnet routing : 
Public subnets route their outbound internet traffic directly through an Internet Gateway (IGW). Private subnets route their outbound internet traffic through a NAT Gateway, allowing them to download updates while remaining hidden from outside inbound connections.

4. Single NAT Gateway vs. one per AZ : 
A single NAT Gateway is cheaper but creates a single point of failure and incurs cross-AZ data transfer costs. Deploying one NAT Gateway per AZ maximizes availability and keeps traffic local, but significantly increases your hourly AWS bill.



*. Network ACLs via Module

1. NACLs vs. Security Groups : 
Network ACLs (NACLs) act as stateless firewalls that control traffic at the broad subnet boundary. Security Groups act as stateful firewalls that control traffic at the specific, individual instance (resource) level.

2. public_dedicated_network_acl : 
This specific module input instructs Terraform to create a separate, dedicated set of NACL rules applied only to your public subnets, isolating their security posture from your private subnets.

3. Defining rules via module : 
The public_inbound_acl_rules and public_outbound_acl_rules inputs allow you to define exactly which IP blocks and ports are allowed or denied from entering and leaving your public subnets directly inside the module block.

4. Why block everything except what we need : 
Denying all traffic by default and explicitly allowing only required ports (like 80 for HTTP or 443 for HTTPS) minimizes your network's attack surface. This adheres to the fundamental security principle of least privilege.