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

variable "origins" {
  description = "Additional origins, supplementary to the default origin created from the S3 bucket"
  default = []
  type = list(object({
    origin_id                        = string
    domain_name                      = string
    origin_path                      = string
    origin_protocol_policy           = string
    duplicate_content_penalty_secret = string
  }))
}

variable "ordered_cache_behaviors" {
  description = "Additional routing behaviors"
  default     = []
  type = list(object({
    min_ttl          = string
    default_ttl      = string
    max_ttl          = string
    path_pattern     = string
    target_origin_id = string
    cookies_forward  = string
    event_type       = string
    lambda_arn       = string
    include_body     = bool
  }))
}