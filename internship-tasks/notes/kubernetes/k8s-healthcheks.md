*. Liveness Probe

1. What a Liveness Probe Does :: 
A liveness probe in Kubernetes checks whether a container is still healthy and functioning correctly. It helps Kubernetes detect applications that are stuck, frozen, or unable to recover on their own. If the application is unhealthy, Kubernetes can take corrective action automatically.

2. Failed Liveness Probe Causes Restart :: 
When a liveness probe fails repeatedly based on its configured thresholds, Kubernetes restarts the container automatically. This restart mechanism helps recover applications from temporary failures or deadlock situations. It is an important part of Kubernetes self-healing behavior.

3. Liveness Probe and Service Endpoints :: 
A failing liveness probe does not immediately remove the Pod from Service endpoints. Its main purpose is to determine whether the container should continue running or be restarted. Traffic handling is controlled separately through readiness probes.



*. Readiness Probe

1. What a Readiness Probe Does :: 
A readiness probe checks whether the application inside a Pod is ready to receive traffic. Even if the container is running, the application may still be starting, loading data, or initializing dependencies. The readiness probe ensures traffic is only sent to healthy and fully ready applications.

2. Failed Readiness Probe Removes Pod from Traffic :: 
If a readiness probe fails, Kubernetes removes the Pod from the associated Service endpoints. This means the Pod stops receiving traffic temporarily while still continuing to run. Once the readiness probe succeeds again, the Pod is automatically added back to the Service.

3. No Restart from Readiness Failure :: 
Readiness probe failures do not restart the container because the application may recover naturally. Kubernetes simply waits until the application becomes ready again. This helps avoid unnecessary restarts during temporary slowdowns or dependency issues.



*. Startup Probe

1. Purpose of Startup Probe :: 
A startup probe is designed for applications that take a long time to initialize. It prevents Kubernetes from checking liveness or readiness too early during startup. This is especially useful for large applications, databases, or services with slow boot times.

2. Preventing Premature Restarts :: 
Without a startup probe, Kubernetes may think a slow-starting application is unhealthy and restart it repeatedly. The startup probe gives the application enough time to fully initialize before health checks begin. This prevents unnecessary restart loops during startup.

3. Handover to Liveness and Readiness :: 
Once the startup probe succeeds, Kubernetes starts using the liveness and readiness probes normally. The startup probe only works during the application initialization phase. After startup is complete, regular health monitoring takes over.



*. Self-Healing

1. Automatic Container Restart :: 
Kubernetes automatically restarts failed containers based on the Pod restart policy. If a container crashes or exits unexpectedly, Kubernetes attempts to recover it automatically. This improves application availability and reduces manual intervention.

2. Deployments Maintain Replica Count :: 
Kubernetes Deployment ensures the desired number of Pod replicas are always running. If a Pod fails or is deleted, Kubernetes automatically creates a replacement Pod. This guarantees application availability and resilience.

3. ReplicaSet Handles Pod Replacement :: 
Pod replacement is managed internally by the ReplicaSet controller created by the Deployment. The ReplicaSet continuously monitors the actual number of running Pods compared to the desired count. If the count decreases, it automatically creates new Pods to restore the desired state.