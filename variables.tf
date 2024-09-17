variable "codebuild_credentials" {
  type = string
}

variable "codestar_connector_credentials" {
  type = string
}

variable "codebuild_image" {
  type = string
  description = "Docker image to use for CodeBuild Project"
  default = "hashicorp/terraform:1.9.5"
}