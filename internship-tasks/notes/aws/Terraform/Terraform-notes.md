*. Infrastructure as Code (IaC)

1. What is IaC and why does it matter?
Infrastructure as Code (IaC) is the practice of provisioning and managing computing infrastructure through machine-readable code rather than manual processes. It matters because it enables automation, ensures consistent environments, allows for version control, and dramatically speeds up deployment times.

2. Declarative vs. Imperative approaches?
In a declarative approach, you write code that specifies what the final desired state of the infrastructure should be, and the tool figures out how to achieve it. In an imperative approach, you write step-by-step commands detailing how to achieve that desired state.

3. How Terraform fits into the DevOps toolchain?
Terraform serves as the core provisioning tool that builds the foundational cloud infrastructure required for applications to run. It bridges the gap between software development and deployment by allowing teams to safely version and deploy infrastructure changes alongside application code.



*. Terraform Core Concepts

1. Providers (What they are, how they connect to AWS)?
Providers are plugins that allow Terraform to interact with cloud platforms, SaaS tools, and external APIs. To connect to AWS, the AWS Provider uses your securely configured credentials (like an Access Key and Secret Key) to authenticate and make API calls on your behalf.

2. Resources (The building blocks)?
Resources are the fundamental building blocks of a Terraform configuration that represent specific pieces of infrastructure, such as a virtual network, compute instance, or database. Each resource block contains the declarative settings needed to create and manage that single component.

3. Variables and Outputs?
Variables allow you to pass dynamic input values into your Terraform code, making your configurations modular and reusable across different environments. Outputs act like return values, displaying essential information about your created infrastructure (like a public IP address or a database endpoint) after a successful deployment.

4. terraform init, plan, apply, destroy?
* terraform init initializes the directory by downloading required provider plugins.
* terraform plan previews the exact changes Terraform will make to your infrastructure.
* terraform apply executes those changes to build or modify the resources.
* terraform destroy safely tears down all resources managed by that specific configuration.

5. 1The plan/apply workflow and why plan matters before apply?
This workflow consists of writing code, running a plan to review proposed changes, and executing the apply to commit them. Running terraform plan is a crucial safety checkpoint that allows you to catch destructive errors and verify exactly what will be created, modified, or deleted before real-world changes occur.




*. Terraform State

1. What is the state file and why does Terraform need it?
The state file (terraform.tfstate) is a JSON document that maps your Terraform configuration to the real-world resources currently deployed. Terraform needs it to track metadata, understand resource dependencies, and calculate the differences between your code and the actual live environment.

2. What happens if you lose the state file?
If you lose the state file, Terraform completely loses its mapping of your code to the existing infrastructure. Running an apply will attempt to recreate all resources from scratch, which will cause deployment failures, duplicate infrastructure, and require a complex manual recovery.

3. Local state vs. Remote state?
Local state stores the state file directly on your machine's hard drive, which is only suitable for solo, non-critical testing. Remote state stores the file in a centralized, shared backend (like cloud storage), which is essential for team collaboration, security, and maintaining a single source of truth.

4. Remote state with S3 backend?
Using an S3 backend means Terraform automatically saves and retrieves your state file from a secure Amazon S3 bucket. This provides high durability, seamless access for distributed teams, and allows you to enable versioning to recover from accidental state corruptions.

5. State locking with DynamoDB — why it prevents corruption?
State locking ensures that only one person or automated pipeline can modify the Terraform state at any given time. By using an Amazon DynamoDB table to lock the state file during an operation, it prevents race conditions and data corruption that would occur if two team members ran terraform apply simultaneously.




*. Terraform File Structure

1. main.tf — resources?
main.tf is the primary entry point of your configuration where you define the actual infrastructure resources you want to build. This is where the core logic and declarative code for your project lives.

2. variables.tf — input variables?
variables.tf is the file used to declare all the input variables required by your Terraform code. It defines variable names, types, descriptions, and default values to keep your code organized and strictly typed.

3. outputs.tf — output values?
outputs.tf defines the specific data points you want Terraform to display or export after it finishes provisioning. This file is highly useful for extracting connection details needed by other systems or developers.

4. terraform.tfvars — variable values?
terraform.tfvars is a file where you assign actual, environment-specific values to the variables you declared in variables.tf. Because it often contains sensitive data or specific environment configurations, it should generally be ignored by version control (Git) to prevent security breaches.

5. .terraform/ directory and .terraform.lock.hcl?
The .terraform/ directory is a hidden folder created during init that stores downloaded provider plugins and backend configurations. The .terraform.lock.hcl file strictly records the exact versions of those providers installed, ensuring that anyone else running the code uses the exact same dependencies to prevent unexpected behavior.