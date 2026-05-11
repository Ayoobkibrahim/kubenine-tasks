provider "aws" {
  region = var.region
}


resource "aws_iam_role" "task-3-42-app-role" {
  name = "task-3-42-app-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}


resource "aws_iam_policy" "task-3-42-custom-s3-policy" {
  name = "task-3-42-custom-s3-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = "*"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "custom_policy_attach" {
  role       = aws_iam_role.task-3-42-app-role.name
  policy_arn = aws_iam_policy.task-3-42-custom-s3-policy.arn
}


resource "aws_iam_role_policy" "task-3-42-cloudwatch-inline-policy" {
  name = "task-3-42-cloudwatch-inline-policy"
  role = aws_iam_role.task-3-42-app-role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

data "aws_iam_policy" "s3_readonly" {
  arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "aws_managed_attach" {
  role       = aws_iam_role.task-3-42-app-role.name
  policy_arn = data.aws_iam_policy.s3_readonly.arn
}