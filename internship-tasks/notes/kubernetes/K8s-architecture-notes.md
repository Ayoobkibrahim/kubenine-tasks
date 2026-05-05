*. Control Plane Components

1. What is the API Server? :: 
The API Server is the front door and central brain of the Kubernetes cluster. Every single command you or the system makes must pass through it to be checked and executed.

2. What is etcd?
etcd is the highly secure memory bank of the cluster that stores its entire configuration and current state. It is so critical that if etcd crashes and loses its data, the entire cluster forgets what it is supposed to be doing.

3. What does the Scheduler do? :: 
The Scheduler acts as a smart dispatcher that decides exactly where new pods should live. It looks at the hardware needs of a pod and assigns it to the worker node that has the best available space and resources.

4. What is the Controller Manager? :: 
The Controller Manager is a continuous background monitor. It constantly compares what is actually running in the cluster against what you requested, and immediately makes fixes if there is a mismatch.



*. Worker Node Components

1. What is the kubelet? :: 
The kubelet is a small agent running on every worker node that takes direct orders from the central API Server. It acts as the node's local manager, making sure the assigned containers are actively running and healthy on that specific machine.

2. What is kube-proxy? ::
Kube-proxy is a network manager running on each node that handles routing rules. It acts as a traffic cop, ensuring that network requests smoothly find their way to the correct pods.

3. What is a Container Runtime? ::
The container runtime (like containerd) is the actual software engine installed on the node. While Kubernetes gives the management orders, the runtime does the physical heavy lifting of pulling images and executing the containers.



*. Cluster Concepts

1. What exactly is a Kubernetes cluster? :: 
A Kubernetes cluster is simply a group of connected machines working together as a single system. It is made up of a "control plane" that manages the logic, and "worker nodes" that provide the computing power to run your applications.

2. How do all components communicate? :: 
To keep the system secure and organized, no component talks directly to another. Instead, every single piece of the cluster—from nodes to schedulers—communicates strictly by sending messages through the central API Server.

3. Why are etcd and the API Server the most critical components? :: 
The API Server is the only way to give or receive commands, and etcd is the only place the cluster's memory is stored. If either of these goes down, the cluster becomes completely paralyzed and cannot be managed.

4. What is High Availability at the control plane level? ::
High availability means running multiple backup copies of the control plane (for example, having 3 API servers and 3 etcd databases spread across different machines). This ensures that if one management server physically crashes, the backups instantly take over and the cluster never goes offline.