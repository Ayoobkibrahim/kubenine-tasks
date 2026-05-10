*. Resource Requests

1. Minimum Resources Required by a Pod :: 
Resource requests define the minimum amount of CPU and memory a Pod needs to run properly in Kubernetes. Kubernetes uses these values to decide where the Pod can be scheduled. Requests help ensure the Pod gets enough resources for stable operation.

2. Used Only During Scheduling :: 
Requests are used only by the Kubernetes scheduler when selecting a node for the Pod. They are not strict runtime limits and do not prevent the container from using more resources if available. Their primary purpose is intelligent resource allocation during scheduling.

3. High Requests Cause Pending Pods :: 
If a Pod requests more CPU or memory than any node can provide, Kubernetes cannot schedule it. In this situation, the Pod remains in the Pending state. This usually indicates insufficient cluster capacity or incorrectly sized requests.



*. Resource Limits

1. Maximum Runtime Resource Usage :: 
Resource limits define the maximum amount of CPU or memory a container can consume while running. Kubernetes enforces these limits during runtime to prevent containers from using excessive resources. Limits help protect cluster stability in multi-tenant environments.

2. Memory Limit and OOMKill :: 
If a container exceeds its configured memory limit, the Linux kernel terminates it using an Out Of Memory Kill (OOMKill). This happens because memory cannot be compressed or shared beyond safe limits. The container usually restarts automatically if managed by a Deployment.

3. CPU Limit and Throttling :: 
When a container exceeds its CPU limit, Kubernetes does not terminate it. Instead, the container is throttled and receives reduced CPU processing time. This slows application performance but keeps the container running.



*. Scheduling Basics

1. How the Scheduler Places Pods :: 
The Kubernetes scheduler places Pods onto nodes based on available allocatable resources like CPU and memory. It compares Pod requests with node capacity before making placement decisions. The goal is to distribute workloads efficiently while avoiding resource exhaustion.

2. Unsatisfied Requests Cause Pending State :: 
If no node has enough available resources to satisfy a Pod’s requests, the scheduler cannot place the Pod. The Pod then remains in the Pending state until resources become available. This helps prevent overloading cluster nodes.

3. Over-Commitment and Under-Sizing Risks :: 
Over-committing resources can cause node instability and application failures during high load. Under-sizing requests may lead to poor scheduling decisions and resource starvation. Correctly sizing requests and limits is important for stable and predictable cluster behavior.



*. Resource Reliability Concepts

1. OOMKill :: 
OOMKill occurs when a container exceeds its memory limit and the Linux kernel forcefully terminates it. This protects the node from running out of memory completely. Frequent OOMKills usually indicate incorrect memory limits or memory leaks in the application.

2. CPU Throttling :: 
CPU throttling happens when a container attempts to use more CPU than its configured limit. Instead of killing the container, Kubernetes restricts CPU usage temporarily. This can reduce application performance under heavy load.

3. QoS Classes :: 
Kubernetes assigns Pods to QoS (Quality of Service) classes based on configured requests and limits. Guaranteed Pods have equal requests and limits, Burstable Pods have partial resource guarantees, and BestEffort Pods have no requests or limits. QoS classes affect scheduling priority and eviction behavior during resource pressure.

4. Risks of Missing Requests and Limits :: 
Missing requests and limits can make workloads unpredictable in shared clusters. A single container may consume excessive resources and impact other applications on the same node. Proper resource configuration improves stability, fairness, and cluster reliability.