*. Amazon EKS (Elastic Kubernetes Service)

1. What is EKS & Managed Control Plane :: 
Amazon EKS is a managed Kubernetes service where AWS runs and maintains the Kubernetes control plane (API server, etcd, scheduler) for you. A managed control plane means AWS handles availability, scaling, and patching of these components automatically. This allows you to focus only on deploying and managing applications instead of maintaining cluster internals.

2. What AWS Manages vs Your Responsibility :: 
AWS manages the control plane, including scaling, patching, and high availability of core Kubernetes components. You are responsible for worker nodes, applications, networking configurations, and security policies inside the cluster. In simple terms, AWS manages the “brain” while you manage the “workloads and infrastructure usage.”

3. Why At Least Two Subnets in Different AZs ::
EKS requires at least two subnets in different Availability Zones to ensure high availability and fault tolerance. If one AZ fails, workloads can still run in another AZ without downtime. This setup is critical for production-grade resilience and uptime.

4. Cluster IAM Role vs Node IAM Role :: 
The cluster IAM role allows the EKS control plane to interact with AWS services like load balancers and networking. The node IAM role is attached to worker nodes and gives them permissions to pull images, write logs, and communicate with AWS services. Both roles serve different purposes and must be configured correctly for cluster functionality.



*. Managed Node Groups

1. Managed Node Group vs Self-Managed Nodes :: 
A managed node group in EKS is a set of EC2 instances that AWS automatically provisions, updates, and manages. In contrast, self-managed nodes require you to handle scaling, patching, and lifecycle management manually. Managed node groups reduce operational overhead and are recommended for most use cases.

2. Node Groups Backed by Auto Scaling Group :: 
Each managed node group is backed by an Amazon EC2 Auto Scaling group in your AWS account. This ensures nodes automatically scale based on demand and replace unhealthy instances. It provides resilience and cost optimization without manual intervention.

3. Subnets & AZ Spread for Nodes ::
Worker nodes are launched into specified subnets within your VPC. Spreading nodes across multiple AZs improves availability and ensures workloads remain running even if one zone fails. This design supports high availability and balanced workload distribution.



*. EKS Networking & Security

1. Cluster API Endpoint (Public/Private) :: 
The EKS cluster API endpoint is the entry point to interact with the Kubernetes control plane. It can be public (accessible via internet), private (accessible only within VPC), or both for flexibility. Choosing the right mode is important for balancing accessibility and security.

2. Cluster Security Group & Managed ENIs :: 
EKS creates a cluster security group that controls traffic between the control plane and worker nodes. AWS also creates and manages ENIs (Elastic Network Interfaces) to enable communication between components. These ensure secure and reliable networking inside the cluster.

3. Control Plane Communication with Nodes ::
The EKS control plane communicates with worker nodes through ENIs within your VPC. This communication happens securely using defined security group rules. It ensures scheduling, monitoring, and management of workloads happen seamlessly.



*. kubectl & kubeconfig

1. What is kubectl :: 
kubectl is the command-line tool used to interact with Kubernetes clusters. It allows you to deploy applications, inspect resources, and manage cluster operations. It is the primary interface for developers and DevOps engineers.

2. What is kubeconfig :: 
kubeconfig is a configuration file that stores cluster connection details, credentials, and contexts. It tells kubectl which cluster to connect to and how to authenticate. Without kubeconfig, kubectl cannot communicate with the cluster.

3. aws eks update-kubeconfig :: 
The AWS CLI command aws eks update-kubeconfig automatically adds your EKS cluster details into the kubeconfig file. It configures authentication using IAM and sets the correct cluster endpoint. This simplifies connecting kubectl to your EKS cluster.

4. IAM Authentication + Kubernetes Authorization :: 
Accessing an EKS cluster requires both AWS IAM authentication and Kubernetes RBAC authorization. IAM verifies who you are, while Kubernetes determines what actions you can perform. Both layers are required to securely control access.



*. Daily Inspection Commands

1. kubectl get vs kubectl describe :: 
kubectl get is used to list resources like pods, services, and nodes in a simple format. kubectl describe provides detailed information including events, errors, and configurations. Together, they help in quick checks and deep troubleshooting.

2. kubectl logs :: 
kubectl logs is used to view the output logs of a container running inside a pod. It is essential for debugging application issues and understanding runtime behavior. Logs help identify errors, crashes, and misconfigurations.

3. kubectl exec ::
kubectl exec allows you to run commands inside a running container. It is commonly used for troubleshooting, inspecting files, or testing fixes directly inside the container. This provides direct access without needing SSH into nodes.