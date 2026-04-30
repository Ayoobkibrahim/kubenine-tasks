*. ECS Fargate Concepts

1. What is ECS? Cluster, Service, Task Definition, Task :  
Amazon Elastic Container Service (ECS) is a managed container orchestration tool. A Cluster is a logical boundary for your resources, a Service ensures a specified number of containers stay running, a Task Definition is the blueprint (like a docker-compose.yml) detailing how to run them, and a Task is the actual running instance of that container.

2. Fargate vs EC2 launch type — why Fargate for this task :  
The EC2 launch type requires you to manage and patch the underlying virtual machines where your containers run. Fargate is a serverless compute engine where AWS manages the underlying infrastructure, which is ideal for this task because it removes operational overhead and lets you focus entirely on the application.

3. Container definitions: image, port mappings, environment variables, log configuration :  
The container definition is a section within the Task Definition that dictates container behavior. It specifies the Docker image to use, port mappings to receive traffic, environment variables for dynamic app configuration, and log configuration to stream outputs to monitoring tools like CloudWatch.

4. How ECS pulls images from ECR or Docker Hub :  
Before a container starts, the ECS agent uses credentials provided by the Task Execution Role to authenticate with the container registry (like ECR or Docker Hub). It then pulls the specified image over the network to the underlying host so the Task can be launched.



*. ECS Module

1. terraform-aws-modules/ecs/aws — what it provides :  
This official Terraform module simplifies deploying containerized applications by bundling the cluster, services, and necessary IAM policies into a single, reusable package. It enforces AWS best practices out-of-the-box, saving you from writing highly verbose, low-level resource configurations.

2. Creating a cluster and service through the module :  
You define the cluster at the top level of the module, and then nest the service definitions inside it. The module automatically handles the heavy lifting of wiring the service to your load balancer and configuring the VPC networking.

3. Task definition configuration within the service :  
Inside the module's service block, you define the container's physical requirements and configuration, usually via JSON or module variables. This includes allocating specific CPU and memory limits, pointing to the image URI, and passing in environment variables.

4. How the module handles task execution role and task role :  
The module automatically provisions these two distinct IAM roles by default, allowing you to easily attach custom policies to them. This ensures a secure baseline by cleanly separating the permissions needed to start the container from the permissions needed by the running app.



*. IAM Least Privilege for ECS

1. Task Execution Role — what ECS itself needs :  
The Task Execution Role is assumed by the ECS service itself (the underlying infrastructure) before your application starts. It grants permissions to perform infrastructure-level actions, primarily pulling container images from ECR and pushing container logs to CloudWatch.

2. Task Role — what your application code needs :  
The Task Role is assumed by the actual application running inside the container. It contains the runtime permissions your specific code needs to interact with other AWS services, such as reading files from an S3 bucket or fetching database credentials from Systems Manager (SSM).

3. The difference between these two roles is critical :  
Mixing these roles is a major security risk and violates the principle of least privilege. The Execution Role is for AWS to operate your container, while the Task Role is for your application logic to execute its business functions.

4. Granting only the specific S3 and SSM permissions :  
To enforce least privilege, the Task Role's IAM policy should only allow access to the exact resource ARNs (like a specific S3 bucket or a specific SSM parameter path) the app requires. Broad wildcard permissions (like s3:*) should be avoided to prevent catastrophic data exposure if the container is compromised.



*. Full Stack Wiring

1. VPC → ALB (public) → ECS Service (private) → Container :  
External web traffic hits the Application Load Balancer (ALB) residing in a public subnet. The ALB acts as a secure proxy, forwarding that traffic into a private subnet to the ECS Service, which routes the request to the specific port on your running Container.

2. Security group chaining: ALB SG → ECS SG :  
The ALB's security group is open to the internet on standard web ports (80/443). The ECS Tasks' security group is configured to reject all internet traffic, accepting inbound connections only from the ALB's security group, creating a highly secure perimeter.

3. Service discovery and health checks :  
The ALB continuously sends HTTP requests to a specific path (like /health) on your running containers to verify they are functioning correctly. If a container fails this health check, the ALB stops sending it traffic, and the ECS Service automatically terminates and replaces the unhealthy Task.

4. CloudWatch Logs for container output :  
Containers are ephemeral, meaning if they crash, their local logs are permanently lost. By configuring the awslogs driver in your task definition, the container's standard output and error streams are securely sent to CloudWatch Logs, allowing you to troubleshoot past crashes.



*. Monitoring & Alerting

1. ECS-specific CloudWatch metrics: CPUUtilization, MemoryUtilization :  
ECS automatically tracks compute usage and reports it to CloudWatch. CPUUtilization and MemoryUtilization show the percentage of the CPU and memory you reserved in your task definition that is currently being consumed by the application.

2. Creating alarms for both CPU and memory :  
You configure CloudWatch Alarms to trigger when these utilization metrics exceed a critical threshold (e.g., above 85% for 5 minutes). These alarms serve as early warning systems for performance bottlenecks, memory leaks, or signals that you need to scale your infrastructure.

3. Reusing the notify-slack pattern from Task 3.5 :  
When an alarm triggers, it sends a message to an Simple Notification Service (SNS) topic. This topic triggers a previously built Lambda function or AWS Chatbot configuration, which formats the alert and instantly posts it to a Slack channel so the engineering team can respond.