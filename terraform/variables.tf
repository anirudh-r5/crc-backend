variable "aws_region" {
  type        = string
  description = "The AWS region to setup all infrastructure"
  default     = "us-west-1"
}

variable "project_name" {
  type        = string
  description = "The name of the project to be used for all infrastructure setup"
  default     = "CrcBackend"
}
