* Parameter Store vs Secrets Manager

1. When should you use Parameter Store versus Secrets Manager?
Use Parameter Store for simple, non-sensitive configuration values like environment settings, URLs, or feature flags. Use Secrets Manager when you need automatic rotation, encryption, or when storing highly sensitive credentials like database passwords or API keys.

2. What is the main difference between Parameter Store (for configuration) and Secrets Manager (for credentials)?
Parameter Store is designed for plain or lightly sensitive config data and is free for standard parameters. Secrets Manager is specially built for secrets that need strong encryption, automatic rotation, and auditing, making it the secure choice for credentials.

3. What are the cost and feature differences between them?
Parameter Store is cheaper (free tier for Standard parameters, small charge for Advanced) and supports basic storage + hierarchies. Secrets Manager costs more per secret per month + per API call but gives automatic rotation, versioning, and KMS encryption by default.

4. Why do both services exist and when do they overlap?
Both exist because Parameter Store is lightweight and cheap for config, while Secrets Manager focuses on high-security secrets with rotation. They overlap on SecureString parameters, but Secrets Manager is preferred when you need rotation or compliance features.



*  Parameter Types

1. What are the three parameter types in AWS Parameter Store?
String – plain text value (like a URL or timeout).
StringList – comma-separated list of values (like allowed IPs).
SecureString – encrypted value using AWS KMS (like passwords).

2. When should you use each parameter type?
Use String for simple non-sensitive text like API endpoints or version numbers. Use StringList when you need to store multiple values in one parameter (e.g., list of servers). Use SecureString only when the value must stay encrypted at rest and in transit, like database credentials.



* Hierarchical Parameter Naming

1. How does path-based (hierarchical) naming work in Parameter Store?
You name parameters using a slash-separated path like /prod/app/database/host or /dev/team1/feature-flag. This creates a folder-like structure that keeps parameters organized by environment, application, or team.

2. Why is hierarchical naming important?
It makes parameters easy to find, group, and manage. It also allows you to apply IAM policies to an entire path (e.g., give access only to /prod/*) instead of listing hundreds of individual parameters.

3. What is GetParametersByPath and when do you use it?
GetParametersByPath is an API that fetches all parameters under a specific path (like /prod/app/) in one call. It is very useful at application startup to load an entire set of config values together instead of calling GetParameter many times.

3. How can IAM policies use the hierarchy for access control?
You can scope IAM policies to a path like arn:aws:ssm:*:*:parameter/prod/app/*. This way the application can read only parameters under that path and nothing else, following the principle of least privilege.



*  IAM-Based Access Control

1. Why do we need custom IAM policies for Parameter Store?
AWS does not give a narrow managed policy that limits access to only your specific parameters, so we create a custom policy with least privilege. The broad managed policies can accidentally allow access to all parameters in the account.

2. How do you scope access to specific parameter paths in IAM?
In the IAM policy, use the Resource element with the exact path ARN (e.g., arn:aws:ssm:*:*:parameter/dev/app/*). Never use * unless it is absolutely required.

3.What is the difference between ssm:GetParameter and ssm:GetParametersByPath?
ssm:GetParameter is used to fetch a single parameter by its full name. ssm:GetParametersByPath is used to fetch many parameters at once using a path prefix. Both actions are needed depending on whether you want one value or a group of values.

4. Do you need extra permissions for SecureString parameters?
Yes. For SecureString you must also allow kms:Decrypt permission on the KMS key that was used to encrypt the parameter. Without this, the application will get an encrypted value and cannot read the plain text.