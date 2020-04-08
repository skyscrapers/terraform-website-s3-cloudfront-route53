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

variable "not-found-response-code" {
  type    = string
  default = "200"
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

variable "ipv6" {
  type        = bool
  description = "Enable IPv6 on CloudFront distribution"
  default     = false
}

variable "lambda_function_association" {
  type = list(object({
    event_type   = string
    lambda_arn   = string
    include_body = bool
  }))
  description = "Lambda@Edge functions to use"
  default = []
}

variable "cache_default_ttl" {
  type = number
  description = "The default amount of time (in seconds) that an object is in a CloudFront cache before CloudFront forwards another request in the absence of an Cache-Control max-age or Expires header"
  default = 300
}

variable "cache_max_ttl" {
  type = number
  description = "The maximum amount of time (in seconds) that an object is in a CloudFront cache before CloudFront forwards another request to your origin to determine whether the object has been updated"
  default = 1200
}

variable "cache_min_ttl" {
  type = number
  description = "The minimum amount of time that you want objects to stay in CloudFront caches before CloudFront queries your origin to see whether the object has been updated"
  default = 0
}
