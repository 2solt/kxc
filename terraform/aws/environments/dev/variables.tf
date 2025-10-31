variable "name" {
  description = "Name of the application."
  type        = string
}

variable "environment" {
  description = "Environment name."
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

variable "parameters" {
  description = "Map of parameters for Parameter Store"
  type = map(object({
    type  = string
    value = string
  }))
}
