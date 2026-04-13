* Object Storage Concepts

1. What object storage is and how it differs from block (EBS) and file (EFS) storage
Storage types are like different ways to park cars. EBS (Block Storage) is like a private garage attached to your specific house; it is fast and editable in small chunks, perfect for an operating system. EFS (File Storage) is like a shared parking lot for an apartment building; multiple servers can access it at once. S3 (Object Storage) is like a massive valet lot; you hand them your data (the object) and some tags (metadata), they give you a ticket (unique URL), and they park it somewhere in a limitless space. You cannot edit just a piece of the file in S3; you must replace the whole object.


2. The relationship between buckets and objects
A Bucket is the root-level container where your data is stored. An Object is the actual file (an image, a text document, a video) and its associated metadata that you place inside the bucket.


3. Why bucket names must be globally unique
Bucket names form part of the actual web URL used to access the data (e.g., https://my-bucket-name.s3.amazonaws.com). Because DNS URLs must be unique across the internet, your bucket name cannot be used by any other AWS customer in any other account worldwide.


4. S3's flat structure ("folders" are just key prefixes)
Unlike your laptop, S3 does not have a real file system hierarchy with folders inside folders. It is a completely flat structure. If you upload a file named images/profile/pic.jpg, S3 does not create an "images" folder. The entire string images/profile/pic.jpg is simply the name (the Key) of that single object. The AWS Console just uses the / character to create a visual illusion of folders for humans.


5. Region-specific storage with global accessibility
When you create an S3 bucket, you must choose a specific AWS Region (like us-east-1). Your physical data never leaves that region unless you explicitly configure replication. However, because S3 provides a web URL for every object, that data can be accessed globally from anywhere on the internet.



* S3 Storage Classes

1. S3 Standard
This is the default storage class. It offers high durability, high availability, and millisecond latency. You use it for active, frequently accessed data like website images, mobile app assets, or daily data analytics.

2. S3 Standard-IA (Infrequent Access)
This class is for data that is accessed less frequently, but requires rapid access when needed. The monthly storage fee is much cheaper than Standard, but AWS charges you a small data retrieval fee every time you read the data. It is ideal for monthly reports or secondary backups.

3. S3 Glacier
Glacier is an archive storage class designed for data you almost never need to access. The storage cost is incredibly cheap (pennies per terabyte), but the trade-off is retrieval time. It can take anywhere from a few minutes to 12 hours to "thaw" your data before you can download it. It is used for long-term compliance or regulatory archiving.



* Public Access & Static Website Hosting

1. What the "Block Public Access" setting does
"Block Public Access" is an account-level or bucket-level master switch. When turned on, it aggressively overrides any individual bucket policies or ACLs that might accidentally grant public access to your data. It acts as a safety net against human error.


2. Why most S3 data breaches happen
S3 buckets are completely private by default. Data breaches almost always occur because a developer explicitly turns off "Block Public Access" and then writes a misconfigured Bucket Policy (e.g., using Principal: "*" without proper conditions), unintentionally exposing sensitive customer data to the entire internet.


3. How static website hosting works
S3 can function as a highly scalable web server, but only for static content (HTML, CSS, JavaScript, and images). S3 simply delivers these files directly to the user's browser. It cannot execute server-side code like PHP, Python, or Node.js.


4. The difference between the S3 API endpoint and the website endpoint
The API endpoint (e.g., s3.amazonaws.com) is used by developers and scripts to programmatically GET, PUT, and delete objects. The Website endpoint (e.g., s3-website-region.amazonaws.com) is specifically optimized for web browsers. It understands how to serve an index.html file when someone visits the root URL and how to route users to a custom error.html page if a link is broken.



* Pre-signed URLs

1. What a pre-signed URL is and what problem it solves
A pre-signed URL is a temporary, cryptographic web link that grants temporary access to a specific private object in S3. It solves the problem of needing to share a private file with a user without forcing you to make the entire bucket public, and without requiring the user to have AWS IAM credentials.


2. How to generate a time-limited URL for a private object
You generate them using the AWS CLI or an AWS SDK (like Boto3 in Python). Your application uses its own secure IAM credentials to sign the request, specifying the exact object and exactly how long the URL should be valid (e.g., ExpiresIn=900 for 15 minutes).


3. Why pre-signed URLs are preferred over making objects public
It enforces the principle of least privilege. If you are building a video streaming app, you don't want your premium movies to be public on the internet where anyone can download them. Instead, when a paying user clicks "Play", your backend generates a pre-signed URL valid for just a few hours.


4. Expiration behavior
Once the exact time limit specified during generation has passed, the URL instantly expires. If a user tries to click that link or refresh the page a second too late, AWS rejects the request and returns an "Access Denied" (HTTP 403) error.



* S3 Versioning

1. What versioning is and what it protects against
S3 Versioning is a bucket-level feature that keeps multiple variants of an object in the same bucket. It is your primary defense against accidental deletion or overwriting. If a developer accidentally uploads a bad file over a good file, versioning allows you to instantly roll back to the good one.


2. How multiple versions of the same object key are stored
When versioning is enabled, S3 assigns a unique "Version ID" to every upload. If you upload resume.pdf three times, you don't overwrite the file. Instead, S3 stores all three files under the key resume.pdf, each with a different Version ID, and simply serves the newest one by default. You pay storage costs for all three versions.


3. What a delete marker is and how it differs from permanent deletion
When you click "delete" on an object in a versioned bucket, S3 does not actually delete the data. Instead, it places a "Delete Marker" on top of the file. This marker becomes the current version, making the file appear deleted to users, but the underlying data is perfectly safe beneath it. Permanent deletion only happens if you specifically delete a file using its exact Version ID.


4. How to recover a deleted object
Because a standard deletion just adds a Delete Marker, recovery is instantaneous. You simply delete the Delete Marker itself. Once the marker is gone, the previous version of the file pops back up and becomes the current, active version again.


5. Why versioning cannot be disabled once enabled
Due to how S3 structures the data on the backend, once a bucket has versioning turned on, it can never be permanently disabled—it can only be "Suspended." Suspending it means S3 stops creating new versions for future uploads, but all your existing versions remain intact and stored.


* Lifecycle Rules

1. What lifecycle rules automate and why they matter for cost
Lifecycle rules are automated policies you apply to a bucket to manage your objects as they age. They are critical for cost optimization because they automatically move older, less-accessed data to cheaper storage tiers or delete it entirely, saving you from paying premium rates for stale data.


2. How transition rules move objects between storage classes
A transition rule automates the downgrade of storage. You can tell S3, "Take any object that is older than 30 days and automatically move it from Standard storage to Standard-IA."


3. How expiration rules permanently delete objects
An expiration rule dictates the end of an object's life. You can configure S3 to permanently delete any object (or noncurrent versions of an object) once it reaches a certain age, like 365 days.


4. Common patterns (Standard → Standard-IA → Glacier)
The industry standard pattern for cost savings is a waterfall approach:
Day 0 to 30: Data sits in S3 Standard (frequent access).
Day 30: Rule transitions data to S3 Standard-IA (infrequent access, cheaper storage).
Day 90: Rule transitions data to S3 Glacier (archive, cheapest storage).
Day 365: Rule expires and permanently deletes the data.


* Server-Side Encryption

1. What encryption at rest means and why it matters
Encryption at rest means scrambling the data as it is written to the physical hard drives inside AWS data centers. It matters because if a malicious actor somehow breached a physical data center and stole a hard drive, the data would be completely unreadable gibberish without the decryption key.


2. SSE-S3 (Amazon Managed)
This is Server-Side Encryption with Amazon S3 managed keys. It is the default, simplest, and free option. Amazon completely handles generating, storing, and managing the encryption keys for you behind the scenes.


3. SSE-KMS (Customer Managed via KMS)
This uses the AWS Key Management Service (KMS). It is more advanced because it gives you control over the keys. The biggest advantage of KMS is the audit trail: every time an object is decrypted, KMS logs exactly who requested the decryption in AWS CloudTrail, which is critical for compliance and security auditing.


4. Why encryption should always be enabled
It is a fundamental security baseline. In modern cloud architecture, there is almost zero performance penalty for S3 encryption, and it ensures that your data is compliant with privacy frameworks (like HIPAA or GDPR) and protected against physical infrastructure compromise. AWS now automatically enables SSE-S3 on all new buckets by default.


5. The difference between AWS-managed keys and customer-managed keys
With AWS-managed keys (SSE-S3), you trust Amazon to lock the door and hold the key; it requires zero administration. With customer-managed keys (SSE-KMS), you own the padlock and the key; you dictate exactly who is allowed to use the key, and you can mathematically rotate the key at any time for enhanced security.



* S3 Permission Layers

1. How the Public Access Block acts as an account-level safety net
The "Block Public Access" feature is a master override switch. Even if a junior developer writes a bucket policy that accidentally grants public access to everyone on the internet, the Public Access Block will intercept and drop those requests, acting as an impenetrable safety net against human error.


2. Bucket Policy vs IAM Policy
* A Bucket Policy is a resource-based policy. It is attached directly to the S3 bucket and defines "Who is allowed to access me?"

* An IAM Policy is an identity-based policy. It is attached to a user or role and defines "What AWS resources am I allowed to access?"


3. Why ACLs exist but are no longer recommended
Access Control Lists (ACLs) are a legacy access control mechanism from the earliest days of S3. They allow you to grant permissions on individual objects rather than the whole bucket. AWS now strongly recommends disabling ACLs entirely (setting "Bucket owner enforced") and managing all permissions centrally via Bucket Policies, as it is much easier to audit and secure.


4. How Explicit Deny overrides any Allow
The golden rule of AWS IAM evaluation is that an "Explicit Deny" always wins. If you have an IAM policy that allows access, and a Bucket Policy that allows access, but a Service Control Policy (SCP) that denies access, the request is blocked. One Deny trumps a hundred Allows.



* Bucket Policy Structure

1. The JSON structure (Effect, Principal, Action, Resource)
Bucket policies are written in JSON and consist of four main components in a statement:

Effect: Either Allow or Deny.

Principal: Who is requesting access? (e.g., a specific IAM user, an AWS account, or * for anyone).

Action: What are they trying to do? (e.g., s3:GetObject, s3:PutObject).

Resource: Where are they trying to do it? (The exact ARN of the bucket or objects, e.g., arn:aws:s3:::my-bucket/*).


2. How to allow public read access to specific objects
To make a bucket public (like for a static website), you set the Principal to "*" (everyone), the Action to "s3:GetObject", and the Resource to your bucket ARN followed by /*. You must also ensure the Public Access Block is turned off.


3. How to restrict access to a specific IP range
You achieve this by adding a Condition block to the JSON policy. You can write a statement that denies all access unless the request's aws:SourceIp matches your corporate office's specific IP address or CIDR block.


4. Why least privilege matters in bucket policies
Least privilege minimizes the blast radius of a security breach. If an application only needs to read files, its policy should only grant s3:GetObject. If you lazily grant s3:* (all actions), a compromised application could be used to delete your entire database backup bucket.



* Cross-Region Replication (CRR)

1. What CRR is and what problem it solves
Cross-Region Replication is an asynchronous process that automatically copies newly uploaded S3 objects from a bucket in one AWS Region to a bucket in a completely different AWS Region. It solves three main problems: disaster recovery (surviving a regional outage), compliance (storing data in specific geographic borders), and latency (bringing data closer to global users).


2. Why versioning must be enabled on both buckets
AWS requires versioning on both the source and destination buckets to ensure it can accurately track and replicate specific object changes, updates, and delete markers without corrupting the state of either bucket.


3. Why an IAM role is required for replication
S3 needs permission to act on your behalf. You must attach an IAM role to the replication rule so the S3 service has the security clearance to read the data from your source bucket and write it into your destination bucket.


4. What gets replicated and what does not
By default, when you turn on CRR, only new objects uploaded after the rule is created are replicated. Any existing data already sitting in the bucket is ignored. To replicate existing data, you must run an S3 Batch Operations job.


5. Cost implications of replication
CRR effectively doubles your costs. You pay for the storage capacity in the source bucket, the storage capacity in the destination bucket, and the inter-region network data transfer fees to move the data between the two locations.



* IAM Roles vs IAM Users

1. Why roles exist and how they differ from users
IAM Users are permanent identities tied to specific people or applications, using long-term credentials (like passwords). IAM Roles exist to provide temporary, short-term access. A role is not tied to a specific person; instead, it is a set of permissions that any trusted entity can temporarily "wear" to complete a task.


2. Roles are assumed, not logged into
You cannot log into an IAM role using a username and password. Instead, you "assume" a role. When a service or user assumes a role, AWS dynamically generates temporary credentials that allow them to act as that role for a limited time.


3. Why services like EC2, Lambda, and ECS use roles
AWS services need to talk to each other (e.g., an EC2 server needing to read a file from S3). Instead of manually giving the server a permanent password, we attach an IAM Role. The service assumes the role, securely gets what it needs, and we never have to manage or rotate passwords.


4. Why storing access keys on a server is a critical security anti-pattern
Hardcoding long-lived access keys onto an EC2 hard drive or inside application code is incredibly dangerous. If a hacker breaches the server or finds the code on GitHub, they instantly have permanent access to your AWS account. IAM roles prevent this entirely because no permanent keys ever touch the server.



* Trust Policies & Permission Policies

1. The two policy types that make up a role
An IAM Role is fundamentally made of two halves: the Trust Policy and the Permission Policy. Both must be perfectly aligned for access to work.


2. Trust policy defines who can assume the role
The Trust Policy is the gateway. It strictly defines who or what (the Principal) is legally allowed to assume the role. For example, it might say: "Only the AWS EC2 service is trusted to use this role."


3. Permission policy defines what the role can do
The Permission Policy dictates the actual actions the role is authorized to perform once it has been assumed. For example: "You are allowed to GetObject from this specific S3 bucket."


4. Why both must be correct for access to work
If the Trust Policy is wrong, the server is denied permission to assume the role in the first place. If the Permission Policy is wrong, the server can assume the role, but will get an "Access Denied" error the moment it tries to actually touch an AWS resource.


* Instance Profiles

1. What an instance profile is and how it connects to EC2
In AWS, you cannot physically attach an IAM Role directly to an EC2 instance. An Instance Profile is a logical container that wraps around the IAM Role. You attach the Instance Profile to the EC2 server, which acts as the bridge delivering the role's permissions to the virtual machine.


2. How EC2 receives temporary credentials through the metadata service
Once an instance profile is attached, the server automatically queries the Instance Metadata Service (IMDS) at a special local IP address (169.254.169.254). AWS automatically securely injects the temporary credentials into this metadata endpoint so applications running on the server can use them seamlessly.


3. Why credentials are rotated automatically and never stored on disk
Because the metadata service handles the credentials entirely in memory, they are never written to the physical hard drive or configuration files. AWS STS (Security Token Service) automatically rotates these credentials in the background before they expire, ensuring zero downtime and maximum security.



* Temporary Credentials

1. How STS generates short-lived credentials behind the scenes
When a role is assumed, the AWS Security Token Service (STS) acts as a secure ticket booth. It dynamically generates a brand-new set of credentials on the fly, hands them to the requester, and sets a strict expiration timer on them.


2. The three parts of temporary credentials
When STS issues temporary credentials, it always delivers three specific components:
An Access Key ID
A Secret Access Key
A Session Token (the cryptographic proof that these keys are temporary and valid)


3. Why temporary credentials are safer than long-lived access keys
Temporary credentials are self-destructing. Even if an attacker perfectly steals the Access Key, Secret Key, and Session Token from an EC2 instance, the keys will automatically expire and become utterly useless within a short window (typically 15 minutes to an hour). This drastically reduces the window of opportunity for an attack.



* IAM Groups

1. What an IAM group is and how it simplifies permission management
An IAM group is a collection of IAM users. It simplifies permission management by allowing administrators to attach IAM policies to the group as a whole, rather than having to manually attach and track policies for dozens or hundreds of individual users.


2. How users inherit permissions from groups they belong to
When an IAM user is added to a group, they automatically and instantly "inherit" all the permissions defined by the policies attached to that group.


3. Why a user can belong to multiple groups and how permissions combine
In the real world, employees often wear multiple hats. A user can be placed in multiple groups (e.g., the "Developers" group and the "Database-Admins" group). AWS simply combines the permissions; the user's total access is the sum (the union) of all the "Allows" granted across every group they belong to.


4. Why policies should be attached to groups, not directly to users (AWS best practice)
Attaching policies directly to users does not scale. It creates massive overhead and makes security audits nearly impossible. By attaching policies only to groups, you enforce Role-Based Access Control (RBAC), ensuring that access is standardized, easily auditable, and tied to a job function rather than an individual person.



*  Permission Inheritance & Evaluation

1. How permissions from multiple groups are merged for a single user
AWS evaluates permissions globally for the user. If Group A allows reading from S3, and Group B allows writing to DynamoDB, the user simply gets both abilities. The permissions are merged together into one comprehensive list of "Allows."


2. What happens when a user is removed from a group
The permissions are revoked immediately. The instant you remove a user from a group, they lose all access that was granted specifically by that group's policies.


3. How group-based permissions interact with directly attached user policies
AWS treats them equally during evaluation. If a user has a directly attached policy allowing an action, and a group policy allowing a different action, the user gets both. However, mixing the two is considered an anti-pattern in production because it makes troubleshooting access issues much harder.


4. Why explicit deny in any policy still overrides allow from any group
The most sacred rule of AWS IAM evaluation is that an "Explicit Deny" always takes precedence. If a user belongs to a group that explicitly denies deleting S3 buckets, it doesn't matter if they belong to five other groups that allow it—the deny will instantly override all allows and block the action.



* Scalable Permission Design

1. Why direct user policies create operational risk at scale
Direct user policies inevitably lead to "permission creep." When a developer transfers from the backend team to the frontend team, administrators often forget to remove their old backend policies. Over time, that user accumulates dangerous levels of access they no longer need, expanding the blast radius if their account is compromised.


2. How group-based design reduces mistakes during onboarding and offboarding
It centralizes access control. When a new engineer joins, you don't guess which 10 policies they need; you just add them to the "Engineering" group and they are perfectly set up. When they leave the company, removing them from that single group cleanly and completely revokes all their access in one click, leaving no security gaps.

3. Common group patterns
Production environments typically use standardized functional groups:
* Admins: Full AdministratorAccess (tightly restricted, heavily monitored).
* Developers: Read/Write access to dev/test resources, but restricted from production.
* ReadOnly: Ability to view configurations and logs (often for auditors or junior staff).
* BillingAccess: Access to the billing dashboard and cost explorer only (for finance teams).


4. Why this maps directly to how organizations manage access in production
Group-based design perfectly mirrors real-world corporate structure. Organizations don't invent bespoke job descriptions for every single employee; they have defined roles (e.g., "Senior QA Engineer"). IAM groups allow your cloud security architecture to exactly match your HR and operational org chart.