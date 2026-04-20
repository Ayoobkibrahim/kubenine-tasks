* KMS Core Concepts

1. What KMS is and why centralized key management matters
AWS Key Management Service (KMS) is a centralized, fully managed service that lets you create, store, and control the cryptographic keys used to protect your data. Centralized key management matters because it gives you a single pane of glass to audit key usage, automate key rotation, and enforce consistent security policies across your entire AWS environment.

2. The difference between encryption at rest and encryption in transit
Encryption at rest protects your data while it is saved on physical storage (like an S3 bucket or database) so it cannot be read if the physical drive is stolen or compromised. Encryption in transit protects your data while it is traveling over a network (like internet traffic) so it cannot be intercepted or read by eavesdroppers.

3. What a symmetric encryption key is
A symmetric encryption key is a single, secret cryptographic key that is used for both encrypting the plaintext data and decrypting the resulting ciphertext. Because the exact same key does both jobs, it must be heavily protected and securely shared only with authorized users.

4. The difference between AWS managed keys and customer managed keys
AWS managed keys are created, rotated, and managed automatically by AWS on your behalf for use within specific AWS services, giving you a hands-off encryption solution. Customer managed keys are created and fully controlled by you, meaning you have total authority over their access policies, rotation schedules, and deletion.

5. Why customer managed keys provide more control
Customer managed keys allow you to write granular key policies that dictate exactly which users or roles can administer or use the key. They also give you the flexibility to manually disable the key, schedule it for deletion, or rotate it on a schedule that meets your specific compliance requirements.




* Key Policies

1. What a KMS key policy is and how it controls access
A key policy is a resource-based permissions document attached directly to a KMS key that dictates exactly who can access it and what actions they can perform. It is the primary gatekeeper for KMS; without a key policy explicitly granting permission, no one—not even the account root user—can use the key.

2. How key policies differ from IAM policies
While an IAM policy is attached to an identity (like a user or role) to define what AWS services they can interact with, a key policy is attached directly to the KMS resource itself. Think of IAM policies as defining "what this user is allowed to do," while key policies define "who is allowed to use this specific key."

3. Who can administer vs who can use a key
A key administrator is given permissions to manage the lifecycle of the key—such as updating policies, enabling, or deleting it—but typically cannot use it to encrypt or decrypt actual data. A key user is granted permissions strictly to perform cryptographic operations (like kms:Encrypt or kms:Decrypt) without the ability to change the key's security settings.

4. Why both a key policy and an IAM policy may be needed for access to work
For an IAM user to use a KMS key, the key policy must explicitly allow the IAM account to delegate permissions, and the user's IAM policy must also grant them the specific KMS actions. If the key policy doesn't trust the account, or the IAM policy doesn't grant the action, the request will be denied.




* KMS Integration with AWS Services

1. How S3 uses KMS for default bucket encryption
Amazon S3 can be configured to automatically encrypt all new objects when they are uploaded using Server-Side Encryption with AWS KMS (SSE-KMS). When a file is uploaded, S3 seamlessly requests KMS to encrypt the data before saving it to disk, ensuring all stored data is protected by default.

2. How SSM Parameter Store uses KMS for SecureString parameters
When you create a SecureString in AWS Systems Manager (SSM) Parameter Store to store sensitive data like database passwords, SSM uses a KMS key to encrypt that value. When you retrieve the parameter, SSM automatically calls KMS to decrypt it on the fly, provided your IAM role has the right permissions.

3. How applications decrypt data — they need kms:Decrypt permission, not the raw key
Applications never actually see, download, or handle the raw KMS key material itself. Instead, the application sends the encrypted ciphertext to the KMS service via an API call, and if the application has the kms:Decrypt permission, KMS performs the math securely and returns the readable plaintext data.

4. Why KMS-encrypted data cannot be read without the correct permissions
Because the actual cryptographic keys never leave the highly secure KMS boundary, anyone trying to read encrypted data must authenticate with AWS and possess explicit permissions to ask KMS to decrypt it. If an unauthorized user steals an encrypted file or database snippet, it remains completely unreadable mathematical gibberish to them.