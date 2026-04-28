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