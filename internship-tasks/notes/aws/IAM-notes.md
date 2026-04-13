* IAM Core Concepts

1. What IAM is and why it exists
IAM (Identity and Access Management) is the central security control plane of AWS. It exists to answer two fundamental questions: Who is allowed into your AWS account (Authentication), and what are they allowed to do once they are inside (Authorization).


2. The difference between the root user and an IAM user
The Root User is the email address used to create the AWS account. It has absolute, unrestricted power over everything, including billing and account deletion. An IAM User is an identity created within the account, usually representing a specific employee or application, with permissions tightly restricted to only what they need to do their job.


3. Why the root user should never be used for daily operations
Because it has "god-level" access, using the root account daily creates a massive security risk. If a root password is leaked, the entire business can be destroyed. It should only be used to set up the first IAM Admin user, lock it down with MFA, and then locked away.


4. IAM Users vs. Roles vs. Groups (Overview)

Users: Permanent identities with long-term credentials (passwords/access keys). Think of this as an employee's permanent ID badge.

Roles: Identities with temporary credentials, usually assumed by AWS services (like EC2) or federated users. Think of this as a temporary "visitor badge" or a "construction hard hat" worn only while doing a specific job.

Groups: Collections of IAM Users. You attach permissions to the group, and all users inside inherit them. Think of this as a "department" (e.g., the Developers group).




* IAM Policies

1. What an IAM policy is and how it defines permissions
An IAM Policy is a JSON document that explicitly lists out permissions. It defines the Effect (Allow or Deny), the Action (e.g., s3:GetObject), and the Resource (e.g., a specific bucket ARN).


2. AWS Managed vs. Custom (Customer-Managed) Policies
AWS Managed Policies are pre-built by Amazon (like AmazonS3FullAccess). They are easy to use but often grant broader access than necessary. Custom Policies are written by you; they take more effort but allow for highly granular, precise security controls.


4. Identity-based vs. Resource-based policies
* Identity-based policies are attached to the Who (an IAM User, Group, or Role). Example: "Ayoob is allowed to read S3."

* Resource-based policies are attached directly to the What (like an S3 Bucket Policy). Example: "This specific S3 bucket allows anyone from the Marketing team to read it."

5. Policy evaluation logic: explicit deny overrides any allow
By default, everything in AWS is implicitly denied. If a policy grants an "Allow," access is permitted. However, if any policy attached to the user contains an "Explicit Deny" for that action, it instantly overrides all allows. One deny trumps a hundred allows.



* Least Privilege Principle

1. What least privilege means and why it matters
The Principle of Least Privilege means granting a user or service only the minimum level of access required to perform its exact job, and absolutely nothing more. It matters because it minimizes the "blast radius" if a system is hacked or an employee makes a mistake.


2. Why AdministratorAccess is dangerous in production
AdministratorAccess grants the ability to do anything to any resource in the account. In a production environment, if a developer with this access gets hacked or runs a flawed script, there are no guardrails to stop them from accidentally deleting live databases or wiping out the network.


3. Why unused permissions should be removed / Over-permissioning
Over-permissioning creates unnecessary attack vectors. If a junior developer only needs to view logs in CloudWatch but is given full EC2 access, a compromise of their laptop means a hacker can spin up expensive servers to mine cryptocurrency on your company's dime.


* MFA (Multi-Factor Authentication)

1. What MFA is and why it adds a critical security layer
MFA requires a user to provide two pieces of evidence to log in: something they know (a password) and something they have (a physical device like a phone generating a time-sensitive 6-digit code). It makes stolen passwords useless on their own.


2. Why MFA should always be enabled on the root account
Because the root account controls the entire billing and infrastructure lifecycle, a simple password is a catastrophic single point of failure. MFA ensures that even if a hacker guesses or steals the root password, they cannot access the account without physically stealing the account owner's phone.


3. What happens if credentials are compromised but MFA is enabled?
The attacker is stopped at the front door. Even if they have the correct username and password perfectly typed out, the AWS console will prompt them for the 6-digit code. Without physical possession of the user's MFA device, the login fails entirely.