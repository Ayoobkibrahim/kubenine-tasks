* Why Secrets Must Be Externalized

1. Why must secrets be externalized from the code?
Secrets must be externalized because hardcoding them inside the application code or Docker image creates serious security risks. The main principle is to separate configuration (including secrets) from the code so that even if your code goes to GitHub or Docker Hub, the secrets stay safe. This follows the 12-factor app methodology and prevents accidental leaks.

2. What are the risks of hardcoding secrets?
Hardcoding secrets can expose them in version control history, build logs (if someone prints env or logs the secret), and Docker image layers (anyone can run docker history or inspect the image to see the secret). Once leaked, attackers can steal database passwords, API keys, etc., within minutes.

3. Why are environment variables alone not sufficient?
Environment variables are still visible in process lists (ps aux), container metadata, or accidental log files, and they are not encrypted or rotated automatically. They can also leak when someone shares task definitions or ECS/Fargate configs. So we need a proper secret store like Secrets Manager.

4. What is the principle of separating configuration from code?
The principle says your code should be the same everywhere (dev, staging, prod); only the configuration and secrets should change. This keeps your application secure, portable, and easy to audit.


* AWS Secrets Manager

1. What is AWS Secrets Manager and how does it store secrets?
AWS Secrets Manager is a fully managed AWS service that safely stores and rotates secrets such as database credentials, API keys, and OAuth tokens. It stores them as simple key-value pairs or JSON objects that your application can fetch at runtime.

2. How are secrets encrypted at rest in Secrets Manager?
Every secret is automatically encrypted at rest using AWS KMS (Key Management Service). You can use the default AWS-managed key or create your own customer-managed KMS key for extra control and auditing.

3. What are the best secret naming conventions?
Use clear, hierarchical names like /prod/app/database, /dev/team1/api-key, or /shared/monitoring/slack-webhook. This makes it easy to organize secrets by environment, application, or team and helps in applying IAM policies later.

4. How do applications retrieve secrets at runtime?
Your application uses the AWS SDK (boto3 in Python, etc.) to call the GetSecretValue API at startup or when needed. The SDK fetches the latest secret value securely without ever storing it in code or logs.



* IAM-Based Access Control for Secrets

1. Why do we need custom IAM policies for Secrets Manager?
AWS does not provide a narrow managed policy for reading only specific secrets, so we must create our own custom IAM policy. The built-in SecretsManagerReadWrite policy is too broad and gives access to every secret in the account.

2. How do we apply the principle of least privilege to secrets?
We give the application only the exact permissions it needs — usually just secretsmanager:GetSecretValue and nothing else. This follows the least privilege rule so that even if the EC2 instance or Lambda is compromised, the attacker cannot read all secrets.

3. How do we restrict access to specific secret ARNs?
In the IAM policy, we use the Resource element to list only the exact secret ARNs (or ARN patterns like arn:aws:secretsmanager:*:*:secret:prod/app/*). This is called resource-level restriction and is the most secure way.

4. What happens if an application does not have permission to read a secret?
The GetSecretValue API call will fail with an AccessDeniedException. Your application should handle this gracefully (usually by logging the error and stopping or retrying) so you catch permission issues immediately during deployment.



* Runtime Secret Retrieval

1. How do EC2 instances authenticate with Secrets Manager?
The EC2 instance uses its attached IAM role to get temporary credentials automatically. The AWS SDK running inside the application uses these credentials to call Secrets Manager — no need to hardcode any AWS keys.


2. Explain the complete flow of runtime secret retrieval.
Application calls GetSecretValue using AWS SDK.
SDK authenticates using the EC2 IAM role credentials.
Secrets Manager checks the IAM policy, decrypts the secret with KMS, and returns only the plaintext value.
The secret is used in memory and never written to disk.

3. Why is runtime retrieval more secure than baking secrets into AMIs or user data?
Baking secrets into AMI or user data means the secret lives permanently inside the image or instance metadata and can be seen by anyone who has access to the AMI or AWS console. Runtime retrieval keeps the secret only in AWS Secrets Manager and fetches it fresh every time, supports automatic rotation, and gives you audit logs of every access.


