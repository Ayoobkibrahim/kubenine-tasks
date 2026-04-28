*. Cross-Stack References

1. terraform_remote_state data source : 
This data source allows one Terraform project (like a compute stack) to securely read the exported outputs of another, separate Terraform project (like a networking stack).

2. Why this is better than hardcoding : 
Hardcoding resource IDs makes your code brittle and heavily dependent on manual updates. Using remote state references ensures your infrastructure automatically adapts if the underlying resources are recreated or changed.

3. State keys : 
State keys act like unique file paths inside your shared S3 backend. They keep the state files of different projects safely separated so they don't overwrite each other while sharing the same storage bucket.



*. EC2 Module

1. terraform-aws-modules/ec2-instance/aws : 
This official public module simplifies the creation of AWS EC2 instances by bundling compute configurations, storage, and network attachments into one standardized block of code.

2. Key inputs : 
These variables define the server's core identity: its operating system (ami), hardware size (instance_type), network location (subnet_id), SSH access (key_name), and automated startup scripts (user_data).

3. Built-in security group creation : 
The module includes features like create_security_group and security_group_rules, allowing it to automatically generate and attach a basic firewall to the instance without needing external code blocks.

4. Module's SG vs. separate resource : 
You should use the module's built-in security group for simple, one-off rules specific to that instance. Create a separate aws_security_group resource when you have complex firewall rules that need to be shared across multiple different resources or modules.



*. User Data

1. What is user_data and when does it run? : 
User data is a custom script or set of commands passed to an EC2 instance during creation. It executes with root privileges exactly once, immediately after the instance boots up for the very first time.

2. Installing software at boot time : 
It is heavily used to automate server bootstrapping, allowing you to automatically install packages (like an Nginx web server), download code, and start services without manual human intervention.

3. How to debug user_data : 
If your startup script fails, you can SSH into the EC2 instance and inspect the /var/log/cloud-init-output.log file. This log contains the exact console output and error messages generated during the boot process.



*. AMI Data Sources

1. data "aws_ami" : 
This data source acts as a dynamic search query, allowing Terraform to ask the AWS API for the most up-to-date Amazon Machine Image (AMI) that matches your specific criteria.

2. Filtering by owner, name, architecture : 
To find the right image, you apply filters to specify the trusted publisher (like Amazon or Canonical), the operating system's naming pattern, and the CPU architecture (like x86_64).

3. Why hardcoding AMI IDs is bad practice : 
AMI IDs are region-specific and constantly updated with new security patches. Hardcoding them means your code will immediately break if you deploy to a new region or if the vendor deprecates that specific image version.