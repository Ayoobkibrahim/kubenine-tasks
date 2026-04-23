* AWS Lambda

1. What serverless computing means and why it exists

Serverless computing abstracts away server management, allowing you to run code without provisioning, scaling, or patching infrastructure. It exists so development teams can focus entirely on writing business logic while AWS handles the heavy lifting of high availability and resource allocation.

2. How a Lambda function is structured: handler function, event parameter, context parameter

A Lambda function revolves around a "handler," which is the main entry point method that AWS executes when triggered. It receives an "event" object containing the triggering data (like details of an S3 upload) and a "context" object providing runtime information (like execution time remaining).

3. What triggers a Lambda function

Lambda is purely event-driven, meaning it sits idle until triggered by an external source. Common triggers include an S3 file upload, a scheduled EventBridge cron job, an HTTP request coming through API Gateway, or a message arriving in an SQS queue.

4. What an IAM execution role is and why Lambda cannot function without one

The execution role is an IAM identity securely assumed by the Lambda function itself while it runs. Without this role, Lambda is completely isolated and lacks the permissions to interact with other AWS services, such as reading from a database or even writing its own logs to CloudWatch.

5. How Lambda automatically sends all output to CloudWatch Logs

Lambda has native, built-in integration with CloudWatch, meaning any standard console.log or print statements in your code are automatically streamed to CloudWatch Logs. Because you cannot SSH into a serverless function, these logs are your only window into the application's runtime behavior.

6. Lambda pricing model

Lambda uses a pure pay-as-you-go model where you are charged based on the total number of requests and the execution duration, billed down to the exact millisecond. If your code is not actively running, you pay absolutely zero for compute capacity.

7. Cold start vs warm start

A cold start happens when AWS must spin up a brand-new, isolated container to run your code, resulting in a slight latency delay for the user. A warm start occurs when a subsequent request reuses that already-running container, resulting in near-instantaneous execution.

8. Lambda limitations

Lambda is strictly designed for short-lived, lightweight tasks, enforcing a hard maximum execution timeout of 15 minutes per invocation. It also has a maximum memory allocation limit of 10 GB and strict deployment package size limits to keep infrastructure scaling lightning fast.



* Lambda Execution Roles

1. Why Lambda uses an IAM role (not an IAM user or access keys)

Lambda uses an IAM role because it is an automated service, not a human, and requires temporary, automatically rotated security credentials to operate. This eliminates the massive security risk of managing and potentially leaking permanent hardcoded access keys.

2. What a trust policy is

A trust policy is a specific JSON document attached to an IAM role that defines exactly which entity (principal) is allowed to assume it. For a Lambda function, this policy explicitly grants the lambda.amazonaws.com service the right to take on the role.

3. The difference between the trust policy and the permissions policy

The trust policy determines who (or what AWS service) is allowed to assume the role. The permissions policy dictates what actions that role is allowed to perform on which AWS resources once it has been assumed.

4. Why AWSLambdaBasicExecutionRole is needed for CloudWatch Logs access

This managed policy provides the baseline permissions your function needs to create log groups and write standard output to CloudWatch Logs. Without it, your Lambda function will execute completely in the dark, giving you zero visibility into its output or error messages.



* S3 Event Notifications

1. How S3 can send event notifications

S3 can automatically monitor a bucket and trigger an alert whenever an object is created, deleted, or restored. It packages the details of the event into a JSON message and pushes it directly to a destination like Lambda, SQS, or SNS.

2. What the s3:ObjectCreated:* event type covers

This is a wildcard event type that triggers a notification for any action that results in a new object appearing in the bucket. It natively covers Put, Post, Copy, and CompleteMultipartUpload API operations.

3. How to configure S3 to target a Lambda function

Within the S3 bucket's properties, you create an Event Notification rule where you select the specific event types to monitor (like object creation). You then select an existing Lambda function's Amazon Resource Name (ARN) as the final destination for the alert.

4. Why Lambda needs a resource-based policy to allow S3 to invoke it

While the execution role controls what Lambda can do, the resource-based policy dictates what external services are allowed to trigger the Lambda. S3 requires this explicit resource-based permission to be granted so it can securely invoke your function when an event occurs.




* Lambda Function Structure

1. How a Python Lambda handler receives parameters

The handler function is the main entry point executed by AWS, and it receives two parameters: the event and the context. The event is a dictionary containing the actual payload from the trigger (like S3 data), while the context object provides runtime metadata like the function's memory limit and request ID.

2. How to extract S3 event details from the Records array

When S3 triggers a Lambda, it passes the event data as a JSON payload where the specific bucket name and object key are nested inside a list called Records. In Python, you navigate this dictionary structure to extract the exact file details, typically using event['Records'][0]['s3'].

3. How print() output in Lambda automatically goes to CloudWatch Logs

Lambda's serverless runtime environment automatically intercepts your application's standard output and standard error streams. Any simple print() statement in your Python code is instantly captured, timestamped, and forwarded to the function's dedicated CloudWatch Log Stream.



* Least Privilege IAM

1. Why you must never use AmazonS3ReadOnlyAccess on Lambda roles

Broad managed policies like this grant access to every single S3 bucket in your entire AWS account, completely violating the principle of least privilege. If your Lambda code has a bug or is compromised, it could read or leak sensitive data from completely unrelated production buckets.

2. How to write a custom inline policy scoped to a specific bucket ARN

You create a custom JSON permissions document that explicitly allows the necessary actions (like s3:GetObject) and tightly restricts the Resource field strictly to the specific ARN of the bucket your application actually needs.

3. The difference between bucket-level and object-level permissions

Bucket-level permissions (arn:aws:s3:::bucket) apply to actions performed on the bucket container itself, such as listing its contents or changing its configuration tags. Object-level permissions (arn:aws:s3:::bucket/*) apply strictly to the actual files inside the bucket, enabling actions like reading, writing, or deleting data.