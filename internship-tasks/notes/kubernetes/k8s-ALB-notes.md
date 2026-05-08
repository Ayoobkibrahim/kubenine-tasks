*. AWS Load Balancer Controller

1. What AWS Load Balancer Controller Is :: 
AWS Load Balancer Controller is a Kubernetes controller that automatically creates and manages AWS Application Load Balancers (ALBs) and Network Load Balancers (NLBs) for applications running on Amazon EKS. EKS needs this controller because Kubernetes alone cannot directly create AWS-native load balancer resources. It enables deep integration between Kubernetes Ingress resources and AWS networking services.

2. Watching Ingress and Creating ALBs :: 
The controller continuously watches Kubernetes Ingress resources inside the cluster. When an Ingress is created or updated, the controller automatically provisions or modifies ALBs, listeners, and target groups in AWS. This automates external traffic management for Kubernetes applications.

3. Recommended Over Legacy Cloud Provider Path :: 
AWS recommends the AWS Load Balancer Controller instead of the older legacy cloud provider integration because it provides better features, flexibility, and Kubernetes-native behavior. It supports advanced ALB capabilities like path routing, host routing, SSL termination, and target-type configuration. The legacy approach is more limited and less aligned with modern Kubernetes networking practices.



*. ALB on EKS

1. ALB as a Layer 7 Load Balancer :: 
Application Load Balancer operates at Layer 7 of the network model and understands HTTP and HTTPS traffic. It can route requests based on paths, hostnames, headers, and other web-layer information. This makes it ideal for modern web applications and Kubernetes Ingress traffic management.

2. ALB Listeners and Target Groups :: 
When an Ingress resource is applied, the AWS Load Balancer Controller automatically creates ALB listeners and target groups in AWS. Listeners accept incoming traffic on ports like 80 or 443, while target groups forward traffic to Kubernetes Services and Pods. This creates a direct mapping between Kubernetes routing rules and AWS networking resources.

3. Internet-Facing vs Internal ALB :: 
An internet-facing ALB is used when applications must be accessible publicly from the internet. An internal ALB is used for private applications that should only be reachable within the VPC or internal network. The choice depends on whether the application is public-facing or internal-only.

4. Why Two Subnets in Different AZs Are Required :: 
ALBs require at least two subnets in different Availability Zones to provide high availability and fault tolerance. If one Availability Zone fails, the ALB can continue serving traffic from another zone. This design improves reliability and is a mandatory AWS requirement for ALB deployment.



*. Controller Installation Model

1. Controller Runs as a Deployment :: 
The AWS Load Balancer Controller runs inside the Kubernetes cluster as a Deployment, usually in the kube-system namespace. Running as a Deployment ensures high availability and automatic recovery if Pods fail. It continuously monitors Kubernetes resources and communicates with AWS APIs.

2. ServiceAccount and IAM Permissions :: 
The controller uses a Kubernetes ServiceAccount linked with AWS IAM permissions to manage AWS resources securely. These permissions allow it to create and update ALBs, listeners, target groups, and security groups. This integration is commonly implemented using IAM Roles for Service Accounts (IRSA).

3. Helm Installation :: 
Helm is the recommended method for installing the AWS Load Balancer Controller. Helm simplifies deployment, upgrades, and configuration management using reusable charts. It is the standard package management approach in Kubernetes environments.



*. Ingress-to-ALB Traffic Flow

1. Ingress to ALB Creation Flow :: 
The traffic flow starts when a Kubernetes Ingress resource is created in the cluster. The AWS Load Balancer Controller detects the Ingress and automatically provisions an ALB in AWS. This connects Kubernetes application routing with AWS external load balancing.

2. ALB to Service to Pods Flow :: 
The ALB receives incoming traffic through listeners and forwards requests to target groups. The target groups route traffic to Kubernetes Services, which then distribute traffic to backend Pods. This layered flow ensures scalable and reliable application access inside the cluster.