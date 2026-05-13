*. Chart Templates

1. Templates are Kubernetes YAML Files with Go Template Syntax :: 
Helm templates are normal Kubernetes YAML files enhanced with Go template syntax for dynamic value injection. This allows the same template to generate different Kubernetes manifests based on configuration values. Templates make Helm charts reusable and flexible across environments.

2. {{ .Values.key }} :: 
The {{ .Values.key }} syntax retrieves values from the values.yaml file and inserts them into templates during rendering. It allows configuration such as image names, ports, and replica counts to be customized without editing template files. This keeps templates generic and environment-independent.

3. {{ include "chart.fullname" . }} :: 
The {{ include "chart.fullname" . }} syntax calls reusable helper templates defined in _helpers.tpl. It is commonly used for generating consistent names, labels, and resource identifiers across the chart. This reduces duplication and improves maintainability.

4. Templates Must Produce Valid Kubernetes YAML :: 
After Helm renders all templates with their values, the final output must be valid Kubernetes YAML. Invalid syntax or incorrect indentation can cause deployment failures. Commands like helm template and helm lint help verify correctness before installation.



*. values.yaml Design

1. Every Configurable Field Should Have a Default :: 
All configurable settings used in templates should have default values defined in values.yaml. This ensures the chart can be deployed successfully even without custom overrides. Default values also improve usability and documentation clarity.

2. Nothing Should Be Hardcoded in Templates :: 
Templates should avoid hardcoded values such as image names, ports, replicas, or resource names. Instead, all configurable settings should come from values.yaml. This makes charts reusable, scalable, and easier to maintain across environments.

3. Override Files for Environment-Specific Configuration :: 
Override files like values-prod.yaml allow environment-specific settings to be applied without changing the main values.yaml or templates. Different environments can use different replicas, images, domains, or resources while sharing the same chart structure. This improves consistency and reduces duplication.



*. ConfigMap as Application Config

1. ConfigMaps Inject Environment-Specific Configuration :: 
ConfigMaps are Kubernetes resources used to provide configuration data to Pods. Applications can read these values as environment variables or mounted files. This allows the same application image to run with different configurations in different environments.

2. Helm Templates Generate ConfigMaps Dynamically :: 
Helm can generate ConfigMaps dynamically using values from values.yaml. This keeps application configuration centralized and easy to manage. Updating configuration becomes simpler because changes only require modifying values files.



*. Ingress in a Chart

1. Ingress Exposes Applications Externally :: 
Ingress resources allow external users to access applications running inside Kubernetes clusters. They manage HTTP and HTTPS routing to internal Services. Ingress is commonly used for domain-based application access.

2. Host, TLS, and Annotations Should Come from values.yaml :: 
Ingress settings such as domain names, TLS certificates, and annotations should be configurable through values.yaml. Different environments may require different domains, SSL settings, or ingress controller annotations. Keeping these settings in values files makes the chart flexible and reusable.