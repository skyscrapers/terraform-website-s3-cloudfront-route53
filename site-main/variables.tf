variable "region" {
  default = "us-east-1"
}

variable "project" {
  default = "noproject"
}

variable "environment" {
  default = "default"
}

variable "domain" {
}

variable "bucket_name" {
  description = "The name of the S3 bucket to create."
}

variable "bucket_path" {
  description = "The folder in the S3 bucket to serve the website from."
  default     = "/"
}

variable "duplicate-content-penalty-secret" {
}

variable "deployer" {
}

variable "acm-certificate-arn" {
}

variable "routing_rules" {
  default = ""
}

variable "default-root-object" {
  default = "index.html"
}

variable "not-found-response-path" {
  default = "/404.html"
}

variable "tags" {
  type        = map(string)
  description = "Optional Tags"
  default     = {}
}

variable "trusted_signers" {
  type    = list(string)
  default = []
}

variable "forward-query-string" {
  description = "Forward the query string to the origin"
  default     = false
}

variable "price_class" {
  description = "CloudFront price class"
  default     = "PriceClass_200"
}

