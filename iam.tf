# Create IAM Role for CodePipeline
# Allow CodePipeline to assume the role
resource "aws_iam_role" "terraform-codepipeline-role" {
  name = "terraform-codepipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      },
    ]
  })
}

# Create IAM Policy Document
# Allowing use of CodeStar Connection & Full Access to CloudWatch, S3, CodeBuild
data "aws_iam_policy_document" "tf-cicd-pipeline-policies" {
    statement {
      sid = ""
      actions = [ 
        "codestar-connections:UseConnection"
       ]
       resources = ["*"]
       effect = "Allow"
    }
    statement {
      sid = ""
      actions = [
        "cloudwatch:*",
        "s3:*",
        "codebuild:*"
      ]
      resources = ["*"]
      effect = "Allow"
    }
}

# Create IAM Policy using Policy Document
resource "aws_iam_policy" "tf-cicd-pipeline-policy" {
  name = "tf-cicd-pipeline-policy"
  path = "/"
  description = "Pipeline Policy"
  policy = data.aws_iam_policy_document.tf-cicd-pipeline-policies.json
}

# Attach IAM Policy to CodePipeline Role
resource "aws_iam_role_policy_attachment" "tf-cicd-pipeline-policy-attachment" {
  policy_arn = aws_iam_policy.tf-cicd-pipeline-policy.arn
  role = aws_iam_role.terraform-codepipeline-role.id
}

# Create IAM Role for CodeBUild
# Allow CodeBuild to assume the role
resource "aws_iam_role" "terraform-codebuild-role" {
  name = "terraform-codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      },
    ]
  })
}

# Create IAM Policy Document
# Allowing use of Logs, S3, CodeBuild, SecretsManager, IAM
data "aws_iam_policy_document" "tf-cicd-build-policies" {
    statement {
      sid = ""
      actions = [ 
        "logs:*",
        "s3:*",
        "codebuild:*",
        "secretsmanager:*",
        "iam:*"
       ]
       resources = ["*"]
       effect = "Allow"
    }
}

# Create IAM Policy using Policy Document
resource "aws_iam_policy" "tf-cicd-build-policy" {
  name = "tf-cicd-build-policy"
  path = "/"
  description = "Codebuild Policy"
  policy = data.aws_iam_policy_document.tf-cicd-build-policies.json
}

# Attach IAM Policy to CodeBuild Role
resource "aws_iam_role_policy_attachment" "tf-cicd-build-policy-attachment1" {
  policy_arn = aws_iam_policy.tf-cicd-build-policy.arn
  role = aws_iam_role.terraform-codebuild-role.id
}

# Attach PowerUserAccess Policy to CodeBuild Role
resource "aws_iam_role_policy_attachment" "tf-cicd-build-policy-attachment2" {
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
  role = aws_iam_role.terraform-codebuild-role.id
}