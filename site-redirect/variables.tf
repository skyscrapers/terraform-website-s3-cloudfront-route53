// AWS Provider configuration
variable region {}

// S3 Bucket configuration
variable bucket_name {}
variable log_bucket {}
variable log_bucket_prefix {}
variable iam-deployer {}
variable duplicate-content-penalty-secret {}


// Configuration for AWS Tagging
variable environment {}

// Cloudfront configuration
variable acm-certificate-arn {}

// Route 53 configuration
variable domain {}
variable domain_alias {}
variable zone_id {}