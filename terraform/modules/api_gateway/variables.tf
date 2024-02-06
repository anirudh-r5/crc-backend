variable "project_name" {
  type        = string
  description = "The name of the project to be used for all infrastructure setup"
  default     = "CrcBackend"
}

variable "lambda_arn" {
  type        = string
  description = "ARN of the Lambda function to be invoked"
}
