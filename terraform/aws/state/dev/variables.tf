variable "name" {
  description = "Name for S3 bucket"
  type        = string
}

variable "aws_profile" {
  description = "AWS profile."
  default     = "default"
  type        = string
}

variable "aws_region" {
  description = "AWS region."
  default     = "eu-west-1"
  type        = string
}
