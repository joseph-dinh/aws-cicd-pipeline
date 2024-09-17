resource "aws_codebuild_project" "tf-plan" {
  name          = "tf-cicd-plan"
  description   = "Plan stage for TerraForm"
  service_role  = aws_iam_role.terraform-codebuild-role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = var.codebuild_image
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
    registry_credential {
      credential = var.codebuild_credentials
      credential_provider = "SECRETS_MANAGER"
    }
  }
  source {
    type = "CODEPIPELINE"
    buildspec = file("buildspec/plan-buildspec.yml")
  }
}

#

resource "aws_codebuild_project" "tf-apply" {
  name          = "tf-cicd-apply"
  description   = "Apply stage for TerraForm"
  service_role  = aws_iam_role.terraform-codebuild-role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = var.codebuild_image
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
    registry_credential {
      credential = var.codebuild_credentials
      credential_provider = "SECRETS_MANAGER"
    }
  }
  source {
    type = "CODEPIPELINE"
    buildspec = file("buildspec/apply-buildspec.yml")
  }
}

# resource "aws_codepipeline" "cicd_pipeline" {
#   name = "tf-cicd"
#   role_arn = aws_iam_role.terraform-codepipeline-role.arn

#   artifact_store {
#     type = "S3"
#     location = aws_s3_bucket.codepipeline-artifacts.id
#   }

#   stage {
#     name = "Source"

#     action {
#       name = "Source"
#       category = "Source"
#       owner = "AWS"
#       provider = "CodeStarSourceConnection"
#       version = "1"
#       output_artifacts = ["tf-code"]
      
#       configuration = {
#         FullRepositoryId = "joseph-dinh/aws-terraform-automation"
#         BranchName = "master"
#         ConnectionArn = var.codestar_connector_credentials
#         OutputArtifactFormat = "CODE_ZIP"
#       }
#     }
#   }

#   stage {
    
#   }
# }

resource "aws_codepipeline" "cicd_pipeline" {
  name     = "tf-cicd-pipeline"
  role_arn = aws_iam_role.terraform-codepipeline-role.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline-artifacts.id
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["tf-code"]

      configuration = {
        ConnectionArn    = var.codestar_connector_credentials
        FullRepositoryId = "joseph-dinh/aws-cicd-pipeline"
        BranchName       = "main"
        OutputArtifactFormat = "CODE_ZIP"
      }
    }
  }

  stage {
    name = "Plan"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["tf-code"]
      version          = "1"

      configuration = {
        ProjectName = "tf-cicd-plan"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["tf-code"]
      version         = "1"

      configuration = {
        ProjectName = "tf-cicd-apply"
      }
    }
  }
}