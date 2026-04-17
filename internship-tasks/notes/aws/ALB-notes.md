* Application Load Balancer (ALB)

1. What is a Load Balancer and why do we need it? It is a traffic distributor. It automatically spreads incoming application traffic across multiple targets (like EC2 instances or containers). We need it to ensure high availability, prevent any single server from becoming overwhelmed, and provide a single point of contact for clients.

2. ALB operates at Layer 7 (HTTP/HTTPS): Operating at Layer 7 (the Application layer) means the ALB can look inside the actual content of the request. It can make smart routing decisions based on HTTP headers, URLs, or cookies (e.g., sending /api requests to one group of servers and /images to another).

3. Internet-facing vs. Internal Load Balancers:
An internet-facing ALB has public IP addresses and routes requests from clients over the internet to your infrastructure. An internal ALB has private IP addresses and is used to route traffic securely between your own internal tiers (like a frontend web tier talking to a backend API tier).

4. Why ALB must be in public subnets to receive internet traffic:
For an internet-facing ALB to communicate with the outside world, it requires a route to an Internet Gateway (IGW). Only public subnets have this route, allowing the ALB nodes to receive external requests.



* Target Groups & Listeners

1. What is a Target Group?
It is a logical collection of resources—like EC2 instances, ECS containers, or Lambda functions—that actually process the requests. The ALB routes traffic to these groups.

2. What is a Listener?
A listener is a process that checks for connection requests using a specific protocol and port (like HTTPS on port 443). You configure rules on the listener to tell the ALB which Target Group should receive the traffic based on the request.

3. Health checks — how ALB decides if a target is healthy:
The ALB periodically pings a specific path on your application (like /health). If the application returns a success code (usually HTTP 200 OK) within a specific timeframe, the target is marked as healthy.

4. What happens when a target fails health checks:
If a target fails a consecutive number of health checks, the ALB instantly marks it as "unhealthy" and stops routing new traffic to it. Once the target recovers and passes the checks again, the ALB resumes sending it traffic.



* Security Group Design

1. ALB Security Group:
The ALB security group acts as the front door. It should be configured to accept inbound traffic from the internet (0.0.0.0/0) only on specific ports, typically port 80 (HTTP) and port 443 (HTTPS).

2. EC2 Security Group:
The application servers must be locked down. Their security group should only accept inbound application traffic (e.g., port 8080) specifically where the source is the ALB's Security Group ID.

3. Why EC2 should not be publicly accessible in production:
This is about "Defense in Depth." If EC2 instances have public IPs and open security groups, malicious actors can bypass your load balancer, your Web Application Firewall (WAF), and your routing rules to directly attack the servers. Keeping them private forces all traffic through your inspected, secured ALB entry point.



* Multi-AZ Load Balancing

1. Why ALB requires subnets in at least 2 AZs:
AWS enforces a minimum of two Availability Zones for high availability. If a catastrophic failure takes out an entire data center (AZ), the ALB itself will remain online and available in the second AZ.

2. How ALB distributes traffic across AZs:
When "Cross-Zone Load Balancing" is enabled (which is default for ALB), the load balancer node in any AZ can distribute traffic evenly across all healthy targets in all registered AZs, preventing traffic bottlenecks.

3. What happens if all instances in one AZ go down:
The ALB's health checks will detect that the instances in the failing AZ are unresponsive. The ALB will automatically stop sending traffic to the degraded AZ and route 100% of the traffic to the surviving, healthy instances in the remaining Availability Zones.



* Internal vs. Internet-Facing ALB

1. What makes an ALB "internal"?
An internal ALB does not have a public IP address or a publicly resolvable DNS record. It is deployed exclusively into private subnets, meaning it is completely invisible and inaccessible from the public internet.

2. When and why you use an internal ALB in production:
We use them to secure backend services. In a typical three-tier architecture, your frontend (web servers) sits behind an internet-facing ALB. Your backend (APIs, app servers) sits behind an internal ALB. This ensures that the outside world can never directly touch your backend servers—they can only be accessed by your frontend servers.

3. How internal ALBs are accessed:
They are accessed strictly from within the Virtual Private Cloud (VPC), or from corporate networks connected to the VPC via AWS Direct Connect or a VPN.



* Path-Based Routing

1. What are listener rules?
Listener rules are the "if-then" logic applied to an ALB Listener. They tell the load balancer exactly what to do with an incoming request based on specific conditions, such as the URL path, host header, or HTTP method.

2. How path conditions route traffic:
Path-based routing allows a single ALB to direct traffic to different microservices based on the URL. For example, if the request is example.com/api/*, the rule routes it to the API Target Group. If the request is example.com/blog/*, it routes it to the WordPress Target Group.

3. Default rule vs. specific path rules:
Every listener has one Default Rule that cannot be deleted. It acts as a catch-all. If an incoming request does not match any of your specific path rules, the default rule takes over (typically configured to return a fixed 404 error page or route to a default frontend app).

4. Evaluation order of listener rules:
Rules are evaluated strictly by their assigned Priority Number (from lowest to highest). The ALB checks the rule with priority 1; if it matches, it routes the traffic and stops evaluating. If not, it moves to priority 2, and so on, until it hits the default rule.



* Multiple Target Groups

1. Why you use multiple target groups behind one ALB:
It allows for microservices consolidation. Instead of provisioning and paying for a separate load balancer for every single service, you can use one ALB to act as the single front door for dozens of different backend applications, routing traffic intelligently between them.

2. Each target group as a separate backend service:
In a modern architecture, Target Group A might contain NodeJS containers handling user authentication, while Target Group B contains Python EC2 instances handling data processing. The ALB seamlessly bridges the client to the correct independent service.

3. Independent health checks per target group:
This is crucial for blast radius containment. Because each Target Group has its own isolated health checks, an outage in your /blog service will only cause the blog targets to be marked unhealthy. Your /api traffic will continue to flow perfectly without any interruption.



* Network Load Balancer (NLB)

1. NLB operates at Layer 4 (TCP/UDP):
Operating at Layer 4 (the Transport layer) means the NLB only looks at the IP addresses and port numbers (like TCP port 1521 for a database or UDP port 53 for DNS). It does not look inside the packet payload to see what the application data is.

2. No path-based or host-based routing (it doesn't inspect HTTP):
Because it works at Layer 4, the NLB has no concept of HTTP headers, URLs, cookies, or user sessions. It cannot route traffic based on whether a user requests /api or /images—it simply forwards the raw TCP or UDP connection to the target.

3. Static IP support (Elastic IP per AZ):
This is a killer feature for NLBs. Unlike ALBs (whose IPs constantly change behind the scenes), an NLB can be assigned a single, permanent Elastic IP address per Availability Zone. This is essential when external partners or firewalls need to whitelist your application’s IP address.

4. Ultra-low latency and high throughput:
NLBs are built to handle massive, sudden spikes in traffic. They can handle millions of requests per second while maintaining ultra-low latency, making them incredibly efficient for heavy workloads.

5. When NLB is the right choice:
You choose an NLB when you are load balancing non-HTTP protocols (like databases, Redis, or custom TCP/UDP services), when you require extreme network performance (gaming servers, real-time streaming, IoT), or when your corporate security team strictly requires static IP addresses for firewall whitelisting.



* Layer 4 vs Layer 7

1. What "Layer 4" means in practice:
In practice, Layer 4 load balancing is just forwarding packets. It establishes a TCP connection directly from the client to the backend server. The load balancer acts as an ultra-fast router, simply passing the bytes back and forth without caring what those bytes are.

2. What NLB can and cannot do compared to ALB:
An NLB can handle any protocol that runs over TCP or UDP, and it can provide static IPs. An NLB cannot integrate with AWS WAF (Web Application Firewall), it cannot route based on URLs, and it cannot return custom fixed HTTP responses (like a 404 page).

3. Why NLB is faster — less processing per connection:
An ALB has to deeply inspect every single request: it terminates the connection, reads the HTTP headers, evaluates routing rules, and then opens a new connection to the backend. An NLB skips all that deep inspection. It just looks at the port and IP and instantly passes the stream through, resulting in significantly less CPU overhead and faster processing.



*  ALB vs NLB Comparison

1. Feature differences (routing, SSL, static IP, performance):
Routing: ALB has "smart" routing (path, host, header). NLB has "dumb" but fast routing (IP/Port).

2. IP Address: ALB has dynamic IPs. NLB has static Elastic IPs.

Security: ALB integrates with AWS WAF for application-level protection. NLB does not (though it supports AWS Shield for DDoS).

3. Use case differences (web apps vs high-performance TCP services):
If it speaks HTTP/HTTPS (like a React frontend, a REST API, or a microservice web app), you use an ALB. If it speaks anything else (like a PostgreSQL database, an MQTT IoT broker, or a multiplayer game server), or if you need static IPs, you use an NLB.

4. When to choose which in a real architecture:
In modern architectures, you often use both. You might put an Internet-Facing ALB in front of your web servers to handle WAF, HTTPS termination, and smart routing. Then, deep in your private subnets, you might use an Internal NLB to load balance traffic to a cluster of custom TCP logging servers or database replicas. Pick the tool based on the protocol and the required inspection level.