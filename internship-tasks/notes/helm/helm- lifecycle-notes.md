*. Chart Structure

1. Chart.yaml :: 
The Chart.yaml file contains metadata about the Helm chart such as the chart name, version, description, and application version. Helm uses this file to identify and manage the chart. It acts like the identity card of the chart.

2. templates/ :: 
The templates/ directory contains Kubernetes resource templates such as Deployments, Services, and ConfigMaps. Helm dynamically renders these templates using values from values.yaml during installation or upgrades. This makes the chart reusable across different environments.

3. values.yaml :: 
The values.yaml file stores the default configuration values used by chart templates. Users can modify these values to customize deployments without editing template files directly. It helps separate configuration from application structure.

4. _helpers.tpl :: 
The _helpers.tpl file contains reusable helper templates and functions used across chart templates. It reduces duplication by allowing commonly used template logic to be defined once and reused everywhere. This improves chart readability and maintainability.



*. Helm Lifecycle Commands

1. helm lint :: 
The helm lint command checks a Helm chart for syntax errors, formatting problems, and best practice issues. It helps identify mistakes before deployment. This improves chart reliability and reduces deployment failures.

2. helm template :: 
The helm template command renders Kubernetes manifests locally without installing them into the cluster. It allows developers to preview the generated YAML before deployment. This is useful for debugging and validation.

3. helm install :: 
The helm install command deploys a Helm chart into a Kubernetes cluster and creates a release. Helm processes the templates using configuration values before creating resources. It is mainly used for first-time application deployment.

4. helm upgrade :: 
The helm upgrade command updates an existing release with new chart versions or modified values. It allows applications to be updated without deleting existing resources. This supports smooth and controlled deployments.

5. helm history :: 
The helm history command displays all revisions of a Helm release. It shows revision numbers, update times, chart versions, and deployment status. This helps track deployment changes and troubleshoot issues.

6. helm rollback :: 
The helm rollback command restores a release to a previous revision stored in Helm history. It is useful when a deployment fails or introduces problems. Rollback helps quickly recover a stable application state.



*. Release Revisions

1. Every Install and Upgrade Creates a New Revision :: 
Helm automatically creates a new revision whenever a release is installed or upgraded. Each revision represents a snapshot of the release configuration and chart version at that time. This allows changes to be tracked over time.

2. Helm Stores Revision History :: 
Helm maintains a history of all release revisions inside the cluster. This stored history enables rollback to any previous stable version when needed. It improves deployment safety and recovery capabilities.

3. History Helps Audit Changes :: 
Release history allows teams to inspect what changed, when it changed, and which chart version was used. This is important for troubleshooting, auditing, and operational visibility. It also helps maintain deployment accountability in production environments.