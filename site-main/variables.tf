variable "region" {
  default = "us-east-1"
}

variable "domain" {
  type = string
}

variable "bucket_name" {
  type        = string
  description = "The name of the S3 bucket to create."
}

variable "duplicate-content-penalty-secret" {
  type = string
}

variable "deployer" {
  type = string
}

variable "allowed_origins" {
  type = string
}

variable "acm-certificate-arn" {
  type = string
}

variable "routing_rules" {
  type    = string
  default = ""
}

variable "default-root-object" {
  type    = string
  default = "index.html"
}

variable "not-found-response-path" {
  type    = string
  default = "/404.html"
}

#variable "tags" {
#  type        = map(string)
#  description = "Optional Tags"
#  default     = {}
#}

variable "trusted_signers" {
  type    = list(string)
  default = []
}

variable "forward-query-string" {
  type        = bool
  description = "Forward the query string to the origin"
  default     = false
}

variable "price_class" {
  type        = string
  description = "CloudFront price class"
  default     = "PriceClass_200"
}

variable "min_ttl" {
  description = "CloudFront minumun TTl"
  default = "0"
}

variable "default_ttl" {
  description = "CloudFront default TTl"
  default = "300"
}

variable "max_ttl" {
  description = "CloudFront maximum TTl"
  default = "1200"
}

variable "application" {
  type = string
}

variable "environment" {
  type = string
}

variable "project" {
  type = string
}
