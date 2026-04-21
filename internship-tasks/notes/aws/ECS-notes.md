* ECS Core Concepts

1. What ECS is and how it differs from running containers on EC2 directly

Amazon Elastic Container Service (ECS) is a fully managed container orchestration service that automates the deployment, scaling, and management of Docker containers. Unlike running containers directly on EC2, where you must manually install Docker and manage the lifecycle of each container yourself, ECS handles the heavy lifting of scheduling and maintaining your container fleet.

2. What a cluster is

An ECS cluster is a logical grouping of tasks or services. It acts as a boundary that allows you to organize, isolate, and manage your containerized applications and the infrastructure they run on.

3. What Fargate is and why it removes the need to manage EC2 instances

AWS Fargate is a serverless compute engine for containers that works seamlessly with ECS. It entirely removes the need to provision, configure, or scale clusters of virtual machines (EC2 instances), allowing you to focus purely on designing and building your applications.

4. The difference between ECS on EC2 and ECS on Fargate

With ECS on EC2, you are responsible for patching, scaling, and managing the underlying EC2 instances that host your containers. With ECS on Fargate, AWS completely manages the underlying infrastructure, and you only pay for the exact compute and memory resources your containers consume.




* Task Definitions & Tasks

1. What a task definition is?

A task definition is the blueprint or template that describes exactly how container should run, including the image, CPU, memory, and ports.

2. What a task is?

A task is the actual, live running instance of that blueprint on ECS cluster.

3. Why task definitions are versioned (revisions)

Task definitions are versioned into "revisions" so you can safely track changes over time and easily roll back to a previous state if an update fails. Every time you update a task definition, ECS creates a new, immutable revision rather than overwriting the old one.

4. How Fargate requires CPU and memory to be defined at the task level

Because Fargate does not run on traditional EC2 instances with fixed sizes, it needs to know exactly how much computing power to provision for your specific workload. Therefore, you must explicitly declare the total CPU and memory required at the task level so Fargate can allocate the exact right amount of serverless compute.




* Fargate Networking

1. Why Fargate uses the awsvpc networking mode

Fargate mandates the awsvpc network mode to ensure high security and tight integration with standard AWS networking features. This mode provides the exact same level of network isolation and fine-grained control for containers as you would get for traditional EC2 instances.

2. What awsvpc means

The awsvpc network mode assigns each running task its own dedicated Elastic Network Interface (ENI) and a primary private IP address from your VPC. This means your container acts like a first-class citizen on your network, functioning just like a standalone server.

3. Why public IP assignment is needed when running tasks in public subnets

If you place a Fargate task in a public subnet, it needs a public IP address to route traffic through the Internet Gateway. Without a public IP, the task cannot communicate with the internet to pull container images from external registries (like Docker Hub) or serve traffic to external users.

4. How security groups control traffic to Fargate tasks

Just like with traditional EC2 instances, security groups act as stateful virtual firewalls for your Fargate tasks. Because each Fargate task gets its own ENI, you can attach a security group directly to the task to strictly control inbound and outbound traffic at the individual container level.


* ECS Services vs Tasks

1. The difference between running a standalone task and creating a service

A standalone task is a one-off run of your container that stops as soon as the process finishes, ideal for batch jobs. An ECS service is a long-running scheduler that ensures a specified number of tasks are always running, ideal for web servers and APIs.

2. Why services maintain a desired task count and replace failed tasks automatically

Services constantly monitor the health of your application and automatically spin up a new task to replace any that crash or fail. This self-healing mechanism ensures your application maintains high availability without requiring any manual intervention from an engineer.

3. How a service registers tasks with a load balancer target group

When a service spins up a new task, it automatically registers that task's private IP address with the Application Load Balancer's target group. This ensures the load balancer immediately knows where to route incoming user traffic.



* Task Role vs Task Execution Role

1. The Task Execution Role

This IAM role is assumed by the ECS infrastructure itself to perform the setup actions required to start your container. It grants ECS the permissions to pull your Docker image from ECR, push standard output logs to CloudWatch, and retrieve secure environment variables from Secrets Manager during startup.

2. The Task Role

This IAM role is assumed by your actual application running inside the container. It grants your code the permissions it needs to make AWS API calls, such as uploading a file to an S3 bucket or reading a database password from SSM.

3. Why these must be separate roles with different permissions

They are separated to enforce strict security boundaries. The ECS infrastructure shouldn't have access to your application's business data, and your application code shouldn't have permission to modify infrastructure deployment states.

4. Why the Task Role must follow least privilege

The Task Role must be tightly scoped to specific resources (like a single S3 bucket) rather than using broad managed policies. This minimizes the "blast radius" so that if a hacker compromises your container, they cannot access the rest of your AWS environment.



* Private Subnets in the Default VPC

1. Why production containers should run in private subnets with no public IP

Production containers should run in private subnets to completely block direct inbound traffic from the open internet. This isolates your backend services from malicious external scans and attacks, forcing all traffic to pass through your load balancer first.

2. How to create private subnets inside the default VPC

You can create a new subnet within your default VPC and simply ensure its route table does not have a direct route to an Internet Gateway. Additionally, you disable the "auto-assign public IP" setting so resources launched inside it remain completely private.

3. Why private subnets need a NAT Gateway for outbound internet access

Even though the tasks are private, the ECS agent still needs to communicate with external services to pull container images from Docker Hub or reach AWS public APIs. A NAT Gateway placed in a public subnet acts as a secure proxy, allowing outbound requests while still blocking inbound connections.

4. How the ALB in the default public subnets forwards traffic to tasks in private subnets

An Application Load Balancer sits in the public subnets, receives public internet traffic, and acts as a reverse proxy. It then securely forwards that traffic over the AWS private network to the private IP addresses of your tasks running in the private subnets.

5. How the awsvpc network mode gives each task its own ENI and private IP

In the awsvpc network mode, AWS provisions a dedicated Elastic Network Interface (ENI) for every single Fargate task. This grants each task its own distinct private IP address from the subnet, making it behave like a dedicated, addressable server on your network.



* ALB Integration with ECS

1. Why Fargate requires the IP target type

Because Fargate is completely serverless, there are no visible EC2 instances for the load balancer to target. Therefore, the ALB must use the ip target type to route traffic directly to the task's individual ENI and private IP address.

2. How ECS automatically registers and deregisters task IPs

The ECS service acts as the orchestrator for the ALB. When a task passes its initial health checks, ECS registers its IP with the target group, and when a task is stopped or scaled down, ECS deregisters it to safely drain traffic.

3. How health checks determine if a task is ready to receive traffic

The ALB continuously sends HTTP "ping" requests to a specific path (like /health) on your tasks. If a task fails to return a 200 OK status code after a few attempts, the ALB marks it as unhealthy, stops sending it traffic, and ECS will eventually replace it.



* Container Resource Sizing

1. How Fargate requires CPU and memory at the task level

Fargate provisions serverless compute on demand, so you must explicitly declare the exact amount of vCPU and memory required in your task definition. AWS uses these values to allocate the correct hardware limits for your container.

2. What happens when a container exceeds its memory limit (OOM kill)

If your application code consumes more memory than you allocated, the container runtime will abruptly terminate the task with an OutOfMemory (OOM) error. This is a hard limit designed to protect the underlying host node from resource starvation.

3. Why you should start with minimal resources and adjust

You should always start with the minimum estimated resources and monitor your CloudWatch metrics to find the sweet spot. This process, known as right-sizing, prevents your company from overpaying for unused serverless compute capacity.



* CloudWatch Logging

1. How to configure the awslogs log driver

You configure the awslogs log driver directly within your task definition's container settings. This instructs the Docker daemon to automatically capture your container's standard output (stdout) and standard error (stderr) streams.

2. Why container logs must go to CloudWatch for debugging

Because Fargate tasks are ephemeral and you cannot SSH into the underlying server to read local log files, shipping logs to a centralized service like CloudWatch is mandatory. It is the only way to troubleshoot application crashes after a container has been destroyed.

3. How to find and read logs for a specific task

You can view these logs by navigating to the CloudWatch console and opening the specific Log Group defined in your task definition. Inside, you will find individual Log Streams, with each stream corresponding to the logs of one specific task ID.