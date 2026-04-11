* EC2 Core Concepts

1. What is an EC2 Instance?
Amazon EC2 (Elastic Compute Cloud) is a web service that provides virtual servers—called "instances"—in the AWS cloud. Instead of buying and maintaining physical hardware in your own data center, you rent these virtual computers from AWS to run your applications, paying only for the compute power you actually use.


2. Why is it called "Elastic"?
It is called "elastic" because you can instantly scale your compute capacity up or down based on demand. If your application suddenly gets a massive spike in traffic, you can spin up dozens of new EC2 instances in minutes. When the traffic subsides, you can shut them down just as quickly to stop paying for them.

3. What do you control on an EC2 instance?
Unlike managed services where AWS handles the underlying infrastructure, EC2 is an Infrastructure as a Service (IaaS) offering. This means you have complete, root-level administrative control. You choose the operating system, the hardware specifications (CPU and RAM), the storage capacity, and the network firewall rules. Once it is running, it behaves exactly like a physical server sitting on your desk.


4. What an AMI is and how it determines the OS and software
An AMI (Amazon Machine Image) is a master template used to launch an EC2 instance. It contains the specific operating system (like Ubuntu, Amazon Linux, or Windows) and any pre-installed software or configurations you need. When you launch an instance, it becomes a running copy of that exact AMI template.


5. What Instance Types are and how they map to capacity
Instance types are essentially the hardware profiles you choose for your virtual server. They dictate the exact combination of CPU, Memory (RAM), Storage, and Network capacity your instance will have. AWS categorizes them by use case, such as Compute Optimized for heavy processing, or Memory Optimized for large databases.


6. What a Key Pair is and why it is required for SSH access
A key pair is a set of cryptographic keys—one public, one private—used to securely log into your EC2 instance without a password. AWS stores the public key on the instance, and you keep the private key on your local machine. When you try to connect via SSH, the server verifies your private key matches the public key before granting access.


7. The difference between Public IP and Private IP on an EC2 instance
The Private IP is permanently assigned to your instance and is used for internal communication within your VPC (like your web server talking to your database). The Public IP is used to communicate with the outside internet. Unless you attach a static Elastic IP, the default public IP is temporary and belongs to the AWS public pool.



* Security Groups for EC2


1. How a Security Group acts as a virtual firewall
A Security Group operates right at the instance level. It acts as a bouncer, inspecting every single packet of network traffic trying to enter or leave your specific EC2 instance and checking it against the rules you defined. If there is no rule explicitly allowing the traffic, it is blocked by default.


2. Why SSH (port 22) should be restricted to your IP only
Leaving SSH open to 0.0.0.0/0 (the entire internet) is a major security vulnerability. It allows anyone in the world to attempt to brute-force or guess their way into your server. By restricting port 22 to only your specific, current IP address, you ensure that only your machine can even attempt to initiate a login.


3. The difference between Inbound and Outbound rules
Inbound rules control what traffic is allowed to come into your EC2 instance (e.g., allowing external users to hit port 443 for HTTPS). Outbound rules control what traffic your instance is allowed to send out (e.g., allowing your server to connect to an external API or download a software update).


4. What is SSH?
SSH stands for Secure Shell. It is a secure network protocol that gives you an encrypted way to access, manage, and communicate with a remote computer (like an EC2 instance) over an unsecured network (like the public internet). It is the industry-standard tool system administrators use to open a command-line terminal on a remote Linux server.

5. How does it work?
Instead of sending passwords in plain text where attackers could intercept them, SSH encrypts all the traffic between your local computer and the remote server. It typically uses a Key Pair (a public key and a private key) for authentication. When you attempt to connect over Port 22, the server uses the keys to mathematically verify your identity before granting access.

6. Why is it essential for EC2?
Because AWS EC2 instances are virtual servers sitting in a massive data center somewhere else in the world, you cannot just plug a monitor and keyboard into them. SSH is your primary, secure lifeline to log into your virtual server so you can install software, update files, and configure your applications.


* Instance Lifecycle

1. The states an instance moves through
When you launch an instance, it starts in pending while AWS provisions the hardware, then moves to running. If you pause it, it goes to stopping and then stopped. If you decide to permanently delete it, it enters shutting-down and finally becomes terminated.


2. What happens to the public IP when you stop and start an instance
Unless you are using an Elastic IP (which is a static, dedicated IP address), the default public IP assigned to an EC2 instance is released back to the AWS pool the moment the instance is stopped. When you start the instance back up, AWS will dynamically assign it a brand-new, different public IP address.


3. The difference between Stop and Terminate
Stopping an instance is like shutting down your laptop; the virtual machine powers off, you stop paying for hourly compute charges, but your hard drive (EBS volume) is preserved so you can turn it back on later. Terminating an instance is permanent deletion. The virtual machine is destroyed, and by default, its root hard drive is wiped out. You cannot recover a terminated instance.


4. What "Delete on Termination" means for the root EBS volume
"Delete on Termination" is a boolean attribute for EBS (Elastic Block Store) volumes attached to an EC2 instance. When enabled (which is the default for the root OS drive), AWS will automatically delete the hard drive and all its data the moment the EC2 instance is terminated. If disabled, the hard drive will survive and persist even after the instance is destroyed.


*  Public vs Private EC2 Behavior

1. Why an instance in a public subnet is reachable from the internet
For an EC2 instance to be reachable from the outside world, three things must be true: it must have a Public IP address, it must reside in a subnet whose Route Table directs traffic (0.0.0.0/0) to an Internet Gateway, and its Security Group/NACLs must allow the inbound connection.


2. Why an instance in a private subnet is not directly reachable
An instance in a private subnet lacks a direct route to the Internet Gateway in its Route Table, and it typically does not have a Public IP address. Because there is no logical path from the public internet to the instance, external traffic physically cannot reach it.


3. How Route Tables and IGW vs NAT Gateway determine this behavior
The Route Table is the ultimate traffic director. If the route table sends 0.0.0.0/0 (internet-bound) traffic to an Internet Gateway (IGW), it is a public subnet allowing two-way internet traffic. If the route table sends that traffic to a NAT Gateway, it is a private subnet allowing only outbound, one-way internet traffic.


4. Why production workloads typically live in private subnets
It is about minimizing the attack surface. By placing core application servers and databases in a private subnet, you ensure that malicious actors on the internet cannot directly scan, target, or attack your infrastructure. Only specialized, hardened resources (like Load Balancers) sit in the public subnet to act as a secure proxy.


* User Data (Bootstrapping)

1. What User Data is and when it executes
EC2 User Data is a script (usually a bash script on Linux) that you provide to AWS when launching an instance. It is executed automatically by a service called cloud-init at the very end of the boot process, but strictly on the first boot cycle only.


2. How User Data automates instance configuration
Instead of launching an instance, SSHing into it manually, and typing commands to install software, User Data automates this. You can write a script to install a web server (like Nginx), download application code from a repository, and start the service so the server is 100% ready to take traffic the moment it finishes booting.


3. How to verify that User Data ran successfully
You can verify the execution and check for errors by SSHing into the EC2 instance and reading the cloud-init log files. On Amazon Linux or Ubuntu, you would inspect the /var/log/cloud-init-output.log file.


4. What happens if the User Data script fails
If the script encounters an error, the EC2 instance will still boot up and enter the "running" state. AWS does not mark the instance as "failed." However, whatever software or configuration the script was supposed to install will simply be missing or broken.


* Elastic IP

1. What an Elastic IP is and why it exists
An Elastic IP (EIP) is a dedicated, static public IPv4 address that you own and control within your AWS account. It exists so you can mask instance failures; if a server crashes, you can rapidly remap your Elastic IP to a healthy replacement server, and your users (or DNS records) will never know the underlying hardware changed.


2. How it differs from an auto-assigned public IP
An auto-assigned public IP is temporary and belongs to the AWS public pool. An Elastic IP is permanently allocated to your account until you explicitly choose to release it back to AWS.


3. Why the auto-assigned public IP changes on stop/start but an Elastic IP does not
When you stop an instance, AWS reclaims the auto-assigned public IP so another customer can use it. When you start the instance again, AWS dynamically hands you a new, random one. An Elastic IP bypasses this dynamic assignment—it acts as a persistent sticker you manually slap onto the instance, surviving all stop/start cycles.


4. Cost implications of an unused Elastic IP
AWS charges you for Elastic IPs only when they are not being used. If your EIP is attached to a running instance, it is generally free. If the instance is stopped, or if the EIP is just sitting unattached in your account, AWS charges you an hourly fee to prevent customers from hoarding scarce IPv4 addresses.


* Connectivity Troubleshooting

1. How to reason through why an instance is unreachable
When an instance is unreachable, you must troubleshoot chronologically from the outside in. I check the Network level (Does the VPC have an IGW? Does the subnet Route Table point to it?), then the Firewall level (Are NACLs or Security Groups blocking the specific IP/Port?), and finally the Instance level (Does it have a public IP? Is the service actually running on the OS?).


2. The role of Security Groups, Route Tables, and Subnet placement
Subnet placement dictates if the architecture even allows internet access. Route Tables dictate the actual path the traffic must take to get in and out. Security Groups act as the final bouncer at the door of the instance, checking if your specific IP and port combination is on the guest list. If any one of these three layers is misconfigured, the connection times out.


* Instance Resizing

1. Why an instance must be stopped before changing its type
You must stop the instance because resizing requires AWS to migrate your virtual machine to a new underlying physical server that has the appropriate hardware capacity. You cannot change a computer's physical motherboard and CPU while it is powered on.


2. What changes and what stays the same after a resize
Changes: Compute capacity (CPU, RAM, network bandwidth) and your hourly billing rate. The auto-assigned public IP will also change. Stays the same: Your Private IP, Elastic IP (if attached), your EBS volumes, and all your data.


3. When you would resize an instance in production
You resize an instance to "vertically scale." You scale up (e.g., from t3.medium to t3.large) when your application is consistently hitting CPU or memory bottlenecks. You scale down to save money if your monitoring shows the instance is massively over-provisioned and idling most of the time.


* EBS Volumes & Volume Types

1. Root volume vs additional (data) volumes
The Root volume is the drive where the operating system (Linux/Windows) is installed and boots from. Additional volumes are secondary drives attached for application data, databases, or logs (similar to plugging a D: drive into your computer).


2. The "Delete on Termination" flag
It is a safeguard setting. If enabled (which is the default for root volumes), AWS automatically deletes the EBS volume when the EC2 instance is terminated. If disabled (often recommended for critical data volumes), the hard drive survives and persists independently even if the server is destroyed.


3. Difference between gp2, gp3, and io1 volume types
They are all SSD-backed volumes but differ in performance tuning:

gp2: General purpose. Its performance (IOPS) is tied directly to its size. To get more speed, you have to pay for a larger drive, even if you don't need the storage space.

gp3: The newer general purpose standard. It provides a baseline of 3,000 IOPS and allows you to provision extra speed and throughput independently of the storage size.

io1/io2: Provisioned IOPS. Designed for massive, I/O-intensive database workloads where sub-millisecond latency is mission-critical. It is the most expensive option.


4. Why gp3 is generally preferred over gp2 for new workloads
gp3 is up to 20% cheaper per gigabyte than gp2, and it decouples storage capacity from performance. You can crank up the speed without being forced to buy terabytes of storage you don't need.

5. EBS-backed vs Instance Store (Conceptual)
EBS is a network-attached storage drive. It is highly available and your data persists even if the instance stops. Instance Store is a physical hard drive plugged directly into the host server. It is incredibly fast, but it is ephemeral—if you stop the instance or the underlying hardware fails, all data on an Instance Store is permanently lost.


* EBS Expansion

1. How to increase EBS volume size
You can increase the size of an EBS volume directly in the AWS Console or CLI without detaching it or stopping the instance. AWS simply allocates more blocks to the volume on the backend. (Note: You can only increase size, never decrease).


2. The two-step process to expand storage
Expanding storage requires two distinct steps:

AWS Level: Modify the volume size in the AWS Console (e.g., from 20GB to 50GB).

OS Level: SSH into the instance and run specific Linux commands (like growpart and resize2fs) to tell the operating system's file system to recognize and expand into that newly available physical space.


* Snapshots & Custom AMI Creation

1. What an EBS snapshot is
A snapshot is a point-in-time, incremental backup of your EBS volume, stored securely in Amazon S3. "Incremental" means that after your first full snapshot, subsequent snapshots only save the blocks of data that have changed, saving you storage costs.


2. How to create a custom AMI from a snapshot
Once you have a snapshot of a root volume, you can register it as an AMI. AWS bundles the snapshot with instance metadata (like the architecture and virtualization type) so it can be used as a bootable template for new instances.


3. Why custom AMIs are used in production (Golden Images)
Instead of launching a blank Linux server and running a 10-minute User Data script to install software, companies create "Golden AMIs." These are pre-baked templates containing the OS, application code, security agents, and exact configurations. If a server crashes, Auto Scaling can boot a Golden AMI in seconds, and it is instantly ready for production traffic.


* Instance Metadata Service (IMDS)

!. What it is and what endpoint it lives on
IMDS is an on-instance service that allows an EC2 instance to securely query data about itself. It is only accessible from within the instance by curling the non-routable IP address: http://169.254.169.254/latest/meta-data/.


2. What information is available and why it matters
You can retrieve the instance ID, region, VPC details, and most importantly, temporary IAM role credentials. This matters because it allows your application to securely authenticate with other AWS services (like writing to an S3 bucket) without you ever having to hardcode AWS access keys into your source code.


3. The difference between IMDSv1 and IMDSv2
IMDSv1 uses simple HTTP GET requests, which makes it vulnerable to Server-Side Request Forgery (SSRF) attacks if your web application has a vulnerability. IMDSv2 strictly requires a session token generated via an HTTP PUT request first, neutralizing SSRF vulnerabilities and making the server drastically more secure.


* Status Checks
1. System vs Instance status checks and actions
System Status Check: This means the underlying physical AWS hardware or network has failed. Your virtual machine is fine, but the computer it is sitting on is broken. Action: Stop and Start the instance so AWS boots it up on a healthy physical host.

Instance Status Check: This means the underlying hardware is fine, but your operating system is failing (e.g., exhausted memory, corrupted file system, or kernel panic). Action: Reboot the instance, or SSH in to troubleshoot the application memory/CPU logs.


* Lost PEM File Recovery

1. Why losing your PEM file is a serious problem
If you lose your private SSH key and do not have an alternative login method configured, you are entirely locked out of your server. AWS does not keep a copy of your private key, so they cannot recover it for you.

Recovery options
A. SSM Session Manager: If you attached the correct IAM role and the SSM agent is running, you can securely open a terminal from the AWS console without needing an SSH key.

B. The Detach/Reattach Method: Stop the locked instance --> Detach its root EBS volume --> Attach that volume as a secondary drive to a temporary "rescue" instance --> Mount the drive, edit the ~/.ssh/authorized_keys file to inject a new public key --> Unmount, detach, and reattach it to the original instance as the root volume --> Boot it up and log in with your new key.


2. When an instance is truly unrecoverable
You cannot recover an instance if it is backed by an Instance Store volume (because you cannot detach an Instance Store drive) and you do not have SSM Session Manager configured. In that scenario, the instance is a total loss.