# IAM Role for EC2
resource "aws_iam_role" "ec2_services_access_role" {
  name = "ec2-services-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Access to required AWS Services for EC2
resource "aws_iam_role_policy" "ec2_services_access_role_policy" {
  name = "ec2-services-access-role-policy"
  role = aws_iam_role.ec2_services_access_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:DescribeTable"
        ]
        Resource = [
          var.agent_storage_table_values["table_arn"],
          var.agent_storage_table_values["table_index_arn"]
        ]
      },
      {
        Sid    = "AllowNovaLiteInference"
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream"
        ]
        Resource = [
          "arn:aws:bedrock:*::foundation-model/amazon.nova-lite-v1:0",
          "arn:aws:bedrock:${var.region}:${data.aws_caller_identity.current.account_id}:inference-profile/us.amazon.nova-lite-v1:0"
        ]
      },
      {
        Sid    = "AllowKnowledgeBaseQuery"
        Effect = "Allow"
        Action = [
          "bedrock:Retrieve",
          "bedrock:RetrieveAndGenerate",
          "bedrock:GetKnowledgeBase",
          "bedrock:IngestKnowledgeBaseDocuments"
        ]
        Resource = [
          "arn:aws:bedrock:${var.region}:${data.aws_caller_identity.current.account_id}:knowledge-base/*"
        ]
      },
      {
        Sid    = "AllowS3PutObject"
        Effect = "Allow"
        Action = [
          "s3:PutObject"
        ]
        Resource = [
          "${aws_s3_bucket.s3_kb_docs.arn}/*"
        ]
      }
    ]
  })
}

# Attach the Managed Policy for ECR Read-Only access
resource "aws_iam_role_policy_attachment" "ecr_readonly" {
  role       = aws_iam_role.ec2_services_access_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Attach the AmazonSSMManagedInstanceCore policy
resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2_services_access_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Create Instance Profile
resource "aws_iam_instance_profile" "ec2_services_access_instance_profile" {
  name = "ec2-services-access-instance-profile"
  role = aws_iam_role.ec2_services_access_role.name
}
