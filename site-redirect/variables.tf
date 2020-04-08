variable "region" {
  type    = string
  default = "us-east-1"
}

variable "domain" {
  type = string
}

variable "target" {
  type = string
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

variable "tags" {
  type        = map(string)
  description = "Optional Tags"
  default     = {}
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

variable "default_root_object" {
  type        = string
  description = "CloudFront default root object"
  default     = "index.html"
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
