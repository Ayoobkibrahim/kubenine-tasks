* AWS STS (Security Token Service)

1. What STS is and what role it plays in AWS authentication
AWS STS is the web service responsible for creating and distributing temporary security credentials. If IAM is the database of who exists, STS is the ticket booth that actually hands out the temporary passes to access AWS resources.


2. How STS generates temporary credentials on demand
When a trusted user or service requests access, STS generates a brand-new, unique set of credentials on the fly. These credentials are not stored permanently anywhere in AWS; they exist only for the duration of the requested session.


3. The three components of temporary credentials
STS always returns a package with three exact pieces: an Access Key ID, a Secret Access Key, and a Session Token (which provides cryptographic proof that the keys are temporary and valid).


4. Why are temporary credentials fundamentally safer than long-lived access keys?
Temporary credentials are fundamentally safer because they are self-destructing. If an attacker steals them, they only have a very short, limited window of time (often just 15 to 60 minutes) to use them before the credentials automatically expire and become completely useless. Long-lived access keys never expire, meaning a stolen key grants an attacker permanent access to your account until you manually discover the breach and delete the key.



* AssumeRole

1. What the sts:AssumeRole action does
sts:AssumeRole is the specific API command you send to STS to request temporary credentials for a specific IAM role. It is the technical action of "putting on the hat" of the role.


2. The two-sided requirement (Trust + Permission)
Role assumption requires a strict two-way handshake:
* The caller (user/service) must have an IAM Permission Policy that allows them to call sts:AssumeRole.
* The target role must have a Trust Policy that explicitly lists the caller as an allowed entity.
If either side says "no," the request fails.


3. What a role session is and what a session name identifies
A "role session" is the active period where the temporary credentials are valid. The "session name" is a custom identifier passed during the AssumeRole call (e.g., the user's email or an EC2 instance ID). This is critical for auditing because it logs exactly who assumed the role in AWS CloudTrail, rather than just showing that a generic role performed an action.


4. How assumed credentials are scoped to the role's policy
When you assume a role, you temporarily surrender your original permissions. The temporary credentials only grant you the exact permissions defined by the role's permission policy, nothing more.



* Trust Relationships

1. How the trust policy defines which principals can assume it
The Trust Policy is a JSON document attached directly to the role. It defines the Principal—the exact AWS account, IAM user, or AWS service (like EC2 or Lambda) that is legally allowed to assume the role.


2. Trusting an IAM user vs. an AWS service vs. an entire account
* User: You can trust one specific person (e.g., arn:aws:iam::111122223333:user/Ayoob).
* Service: You can trust an AWS machine (e.g., ec2.amazonaws.com).
* Account: You can trust an entire AWS account (e.g., arn:aws:iam::444455556666:root). Note: Trusting an account just means delegating trust; the users in that account still need IAM permissions to assume the role.


3. Why trust policies are the security boundary
Even if an IAM user is granted sweeping AdministratorAccess and has permission to call sts:AssumeRole on anything, they still cannot assume a role if that role's Trust Policy does not explicitly invite them. The target role always has the final say.


4. How misconfigured trust policies create privilege escalation risks
If an engineer creates a role with high-level permissions (like database deletion) but accidentally sets the Trust Policy Principal to "*" (everyone), any user in the account—even a junior dev with read-only access—could assume that role and escalate their privileges to perform destructive actions.



* Credential Expiration

1. Default and configurable expiration times
By default, temporary credentials obtained via AssumeRole last for 1 hour. However, you can configure the duration to be as short as 15 minutes or as long as 12 hours, depending on the role's settings and your security requirements.


2. What happens when credentials expire
Access is silently and instantly denied. The very next API call made with those expired keys will bounce back with an "ExpiredToken" or "Access Denied" error. Your application must request a fresh set of credentials from STS to continue.


3. Why short-lived credentials reduce the blast radius
If an EC2 instance is breached and temporary credentials are stolen, the hacker has a very tight ticking clock. If the credentials expire in 15 minutes, the hacker only has 15 minutes to figure out your environment and execute an attack before their access completely vanishes.


4. How this compares to long-lived access keys
Long-lived keys never expire automatically. If a developer accidentally pushes a long-lived access key to a public GitHub repository, bots will scrape it in seconds, and attackers will have permanent access to mine cryptocurrency on your AWS account until you manually discover the leak and delete the key.