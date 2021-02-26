variable "region" {
  default = "us-east-1"
}

variable "domain" {
  type = list(string)
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
  default     = "0"
}

variable "default_ttl" {
  description = "CloudFront default TTl"
  default     = "300"
}

variable "max_ttl" {
  description = "CloudFront maximum TTl"
  default     = "1200"
}

variable "cors_rule_inputs" {
  type = list(object({
    allowed_headers = list(string)
    allowed_methods = list(string)
    allowed_origins = list(string)
    expose_headers  = list(string)
  }))
  default = null

  description = "Specifies the allowed headers, methods, origins and exposed headers when using CORS on this bucket"
}

variable "enable_lambda_sec_headers" {
  type = list(object({
    event_type = string
    lambda_arn = string
  }))
  default = null

  description = "Specifies the lambda function of security headers"
}

variable "enable_oai" {
  description = "Enable/Disable OAI in CloudFront distribution"
  default     = false
}

variable "versioning" {
  description = "Enable/Disable Bucket versioning"
  default     = false
}

variable "enable_cache_policy" {
  description = "Enable cache policy and origin request policy"
  default     = true
}

variable "cache_policy_default_ttl" {
  description = "Time in seconds, that you want objects to stay in the CloudFront cache"
  default     = "86400"
}

variable "cache_policy_max_ttl" {
  description = "The maximum amount of time, in seconds, that objects stay in the CloudFront cache before CloudFront sends another request to the origin to see if the object has been updated."
  default     = "31536000"
}

variable "cache_policy_min_ttl" {
  description = "The minimum amount of time, in seconds, that you want objects to stay in the CloudFront cache"
  default     = "1"
}

