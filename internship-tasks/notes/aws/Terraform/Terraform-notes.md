*. Infrastructure as Code (IaC)

1. What is IaC and why does it matter? : 
Infrastructure as Code (IaC) is the practice of provisioning and managing computing infrastructure through machine-readable code rather than manual processes. It matters because it enables automation, ensures consistent environments, allows for version control, and dramatically speeds up deployment times.

2. Declarative vs. Imperative approaches?
In a declarative approach, you write code that specifies what the final desired state of the infrastructure should be, and the tool figures out how to achieve it. In an imperative approach, you write step-by-step commands detailing how to achieve that desired state.

3. How Terraform fits into the DevOps toolchain?
Terraform serves as the core provisioning tool that builds the foundational cloud infrastructure required for applications to run. It bridges the gap between software development and deployment by allowing teams to safely version and deploy infrastructure changes alongside application code.



*. Terraform Core Concepts

1. Providers (What they are, how they connect to AWS)? : 
Providers are plugins that allow Terraform to interact with cloud platforms, SaaS tools, and external APIs. To connect to AWS, the AWS Provider uses your securely configured credentials (like an Access Key and Secret Key) to authenticate and make API calls on your behalf.

2. Resources (The building blocks)? : 
Resources are the fundamental building blocks of a Terraform configuration that represent specific pieces of infrastructure, such as a virtual network, compute instance, or database. Each resource block contains the declarative settings needed to create and manage that single component.

3. Variables and Outputs? : 
Variables allow you to pass dynamic input values into your Terraform code, making your configurations modular and reusable across different environments. Outputs act like return values, displaying essential information about your created infrastructure (like a public IP address or a database endpoint) after a successful deployment.

4. terraform init, plan, apply, destroy? : 
* terraform init initializes the directory by downloading required provider plugins.
* terraform plan previews the exact changes Terraform will make to your infrastructure.
* terraform apply executes those changes to build or modify the resources.
* terraform destroy safely tears down all resources managed by that specific configuration.

5. 1The plan/apply workflow and why plan matters before apply?
This workflow consists of writing code, running a plan to review proposed changes, and executing the apply to commit them. Running terraform plan is a crucial safety checkpoint that allows you to catch destructive errors and verify exactly what will be created, modified, or deleted before real-world changes occur.




*. Terraform State

1. What is the state file and why does Terraform need it? : 
The state file (terraform.tfstate) is a JSON document that maps your Terraform configuration to the real-world resources currently deployed. Terraform needs it to track metadata, understand resource dependencies, and calculate the differences between your code and the actual live environment.

2. What happens if you lose the state file?
If you lose the state file, Terraform completely loses its mapping of your code to the existing infrastructure. Running an apply will attempt to recreate all resources from scratch, which will cause deployment failures, duplicate infrastructure, and require a complex manual recovery.

3. Local state vs. Remote state? : 
Local state stores the state file directly on your machine's hard drive, which is only suitable for solo, non-critical testing. Remote state stores the file in a centralized, shared backend (like cloud storage), which is essential for team collaboration, security, and maintaining a single source of truth.

4. Remote state with S3 backend? : 
Using an S3 backend means Terraform automatically saves and retrieves your state file from a secure Amazon S3 bucket. This provides high durability, seamless access for distributed teams, and allows you to enable versioning to recover from accidental state corruptions.

5. State locking with DynamoDB — why it prevents corruption?  : 
State locking ensures that only one person or automated pipeline can modify the Terraform state at any given time. By using an Amazon DynamoDB table to lock the state file during an operation, it prevents race conditions and data corruption that would occur if two team members ran terraform apply simultaneously.




*. Terraform File Structure

1. main.tf — resources? : 
main.tf is the primary entry point of your configuration where you define the actual infrastructure resources you want to build. This is where the core logic and declarative code for your project lives.

2. variables.tf — input variables? : 
variables.tf is the file used to declare all the input variables required by your Terraform code. It defines variable names, types, descriptions, and default values to keep your code organized and strictly typed.

3. outputs.tf — output values? : 
outputs.tf defines the specific data points you want Terraform to display or export after it finishes provisioning. This file is highly useful for extracting connection details needed by other systems or developers.

4. terraform.tfvars — variable values? : 
terraform.tfvars is a file where you assign actual, environment-specific values to the variables you declared in variables.tf. Because it often contains sensitive data or specific environment configurations, it should generally be ignored by version control (Git) to prevent security breaches.

5. .terraform/ directory and .terraform.lock.hcl? : 
The .terraform/ directory is a hidden folder created during init that stores downloaded provider plugins and backend configurations. The .terraform.lock.hcl file strictly records the exact versions of those providers installed, ensuring that anyone else running the code uses the exact same dependencies to prevent unexpected behavior.




*. IAM in Terraform

1. aws_iam_role : 
This resource creates an IAM identity with specific permissions that can be temporarily assumed by an AWS service, user, or application. It strictly requires an "assume role policy" (trust policy) to dictate exactly who or what is allowed to assume it.

2. aws_iam_policy : 
This creates a standalone, customer-managed IAM policy that defines specific permissions (allow/deny rules) for interacting with AWS resources. Because it exists independently, you can reuse and attach this exact policy to multiple roles, users, or groups.

3. aws_iam_role_policy : 
This resource creates an "inline" policy that is embedded directly into a specific IAM role. It is tightly coupled to that single role, cannot be reused elsewhere, and is automatically destroyed if the role itself is deleted.

4. aws_iam_role_policy_attachment : 
This resource acts as the "glue" that attaches a standalone IAM policy (whether AWS-managed or customer-managed) to an IAM role. It simply connects an existing identity to an existing set of permissions.

5. The difference between these three resource types : 
aws_iam_policy creates a reusable, standalone permission set. aws_iam_role_policy creates a strict, single-use policy locked directly inside one role. aws_iam_role_policy_attachment doesn't create permissions at all; it merely links a standalone policy to a role.




*. Policy Types

1. AWS Managed Policy : 
These are pre-built, read-only policies created and maintained entirely by AWS (e.g., AmazonS3ReadOnlyAccess). They are ideal for common, standard use cases and save you the effort of writing standard permission rules from scratch.

2. Customer Managed Policy : 
This is a standalone policy that you write, create, and manage yourself within your AWS environment. It gives you fine-grained control over permissions, supports versioning, and can be reused across multiple different IAM identities.

3. Inline Policy : 
An inline policy is embedded directly into a single IAM user, group, or role, maintaining a strict one-to-one relationship. It is useful when you want to ensure a set of permissions is never accidentally attached to another identity, but it lacks reusability.




*. Trust Policy (Assume Role Policy)

1. What a trust policy does : 
A trust policy is a special resource-based policy permanently attached to an IAM role that explicitly defines who is allowed to assume that role. It acts as a gatekeeper, verifying the identity of the requester before handing over the permissions attached to the role.

2. Who or what can assume this role : 
The trust policy can grant assume-role permissions to a wide variety of entities, known as Principals. These can include AWS services (like EC2 or Lambda needing access to S3), specific IAM users, identity providers, or even external AWS accounts (for cross-account access).

3. JSON structure of a trust policy : 
The JSON format requires a Statement block containing three key elements: an Effect (Allow or Deny), an Action (typically sts:AssumeRole), and a Principal block. The Principal block is the most critical part, as it specifies the exact service, user, or account being granted the trust.




*. Terraform Data Sources

1. data "aws_iam_policy" : 
This data block allows Terraform to query your AWS environment to fetch the details and Amazon Resource Name (ARN) of an existing IAM policy. It is most commonly used to fetch pre-built AWS Managed Policies so you can attach them to your roles without having to hardcode their ARNs.

2. When to use data vs resource : 
Use a resource block when you want Terraform to actively create, modify, or destroy a piece of infrastructure. Use a data block when the infrastructure already exists (either created manually, by AWS, or by a different Terraform project) and you simply need to pull its information into your current configuration in a read-only manner.