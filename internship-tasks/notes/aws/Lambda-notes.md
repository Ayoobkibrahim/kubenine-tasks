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