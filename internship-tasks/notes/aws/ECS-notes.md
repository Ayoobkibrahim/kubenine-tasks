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