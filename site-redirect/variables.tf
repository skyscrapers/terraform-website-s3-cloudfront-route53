variable "region" {
  type    = string
  default = "us-east-1"
}

variable "project" {
  type    = string
  default = "noproject"
}

variable "environment" {
  type    = string
  default = "default"
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

variable "default_root_object" {
  type        = string
  description = "CloudFront default root object"
  default     = "index.html"
}
