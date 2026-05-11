*. Namespaces

1. Resource Isolation in a Cluster :: 
Namespaces in Kubernetes provide logical separation of resources within the same cluster. They allow multiple teams, applications, or environments to share one cluster without interfering with each other. This improves organization, security, and resource management.

2. Namespaced Objects :: 
Resources such as Deployments, Pods, Services, and ConfigMaps exist inside a namespace. Each namespace maintains its own isolated set of these resources. This prevents naming conflicts and allows separate application environments within the same cluster.

3. Cluster-Scoped Objects :: 
Some Kubernetes resources are cluster-scoped and exist outside namespaces. Examples include Nodes, PersistentVolumes, and StorageClasses. These resources are shared across the entire cluster and are accessible globally.


*. RBAC (Role-Based Access Control)

1. Role :: 
A Role defines permissions limited to a single namespace. It specifies which actions are allowed on specific resources within that namespace. Roles are commonly used to give application teams restricted access to their own workloads.

2. ClusterRole :: 
A ClusterRole defines permissions at the cluster level or reusable permissions across multiple namespaces. It can grant access to cluster-scoped resources like Nodes or be shared between namespaces. ClusterRoles are more powerful than regular Roles.

3. RoleBinding :: 
A RoleBinding connects a Role or ClusterRole to a user, group, or ServiceAccount within a specific namespace. It activates the permissions defined in the Role for those subjects. The access remains limited to that namespace.

4. ClusterRoleBinding :: 
A ClusterRoleBinding grants cluster-wide access by binding a ClusterRole to subjects across the entire cluster. It is used for administrators or system-level components requiring broad access. Incorrect use can create major security risks.



*. ServiceAccounts

1. Pod Identity in Kubernetes :: 
A ServiceAccount provides an identity for processes running inside a Pod. Applications use this identity when communicating with the Kubernetes API server. This allows Kubernetes to authenticate and authorize Pod actions securely.

2. Binding RBAC Permissions :: 
RBAC permissions can be attached to a ServiceAccount using RoleBindings or ClusterRoleBindings. This allows Pods to access only the resources they actually need. It follows the security principle of least privilege.

3. Default ServiceAccount :: 
Every namespace automatically includes a default ServiceAccount. If no custom ServiceAccount is specified, Pods use the default one automatically. Using custom ServiceAccounts is recommended for better security and permission control.



*. Least Privilege and cluster-admin Risk

1. Why Broad Permissions Are Dangerous :: 
Broad permissions increase security risk because a compromised workload or user could gain extensive cluster access. Attackers may modify workloads, access secrets, or disrupt infrastructure. Limiting permissions reduces the impact of potential security breaches.

2. Risk of cluster-admin :: 
The cluster-admin role provides unrestricted access to the entire Kubernetes cluster. Any user or Pod with this role can control all resources and potentially compromise the environment completely. It should only be granted when absolutely necessary.

3. Narrowest Possible Permissions :: 
Kubernetes security best practices recommend granting only the minimum permissions required for a task. Access should be limited to specific namespaces, resources, and actions whenever possible. This principle is known as least privilege and helps reduce attack surface.



*. Daily Debugging States

1. CrashLoopBackOff :: 
CrashLoopBackOff means a container repeatedly starts, crashes, and restarts continuously. This usually happens because of application errors, missing dependencies, or incorrect configurations. Troubleshooting typically involves checking container logs and previous container logs.

2. ImagePullBackOff :: 
ImagePullBackOff occurs when Kubernetes cannot pull the container image from the registry. Common causes include incorrect image names, invalid tags, authentication issues, or missing image pull secrets. The Pod cannot start until the image becomes accessible.

3. Pending :: 
A Pod in Pending state means Kubernetes cannot schedule it onto any node. This may happen because of insufficient resources, node taints, or scheduling restrictions. Checking resource requests, node capacity, and scheduler events helps identify the issue.