variable region {
  default = "us-east-1"
}

variable project {
  default = "noproject"
}
variable environment {
  default = "default"
}

variable domain {}
variable target {}
variable duplicate-content-penalty-secret {}
variable deployer {}
variable acm-certificate-arn {}

variable "tags" {
  type        = "map"
  description = "Optional Tags"
  default     = {}
}

variable "price_class" {
  description = "CloudFront price class"
  default     = "PriceClass_200"
}
