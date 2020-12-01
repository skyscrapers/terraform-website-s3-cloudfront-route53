################################################################################################################
## Creates a setup to serve a static website from an AWS S3 bucket, with a Cloudfront CDN and
## certificates from AWS Certificate Manager.
##
## Bucket name restrictions:
##    http://docs.aws.amazon.com/AmazonS3/latest/dev/BucketRestrictions.html
## Duplicate Content Penalty protection:
##    Description: https://support.google.com/webmasters/answer/66359?hl=en
##    Solution: http://tuts.emrealadag.com/post/cloudfront-cdn-for-s3-static-web-hosting/
##        Section: Restricting S3 access to Cloudfront
## Deploy remark:
##    Do not push files to the S3 bucket with an ACL giving public READ access, e.g s3-sync --acl-public
##
## 2016-05-16
##    AWS Certificate Manager supports multiple regions. To use CloudFront with ACM certificates, the
##    certificates must be requested in region us-east-1
################################################################################################################

#locals {
#  tags = merge(
#    var.tags,
#    {
#      "domain" = var.domain
#    },
#  )
#}

################################################################################################################
## Configure the bucket and static website hosting
################################################################################################################

data "template_file" "bucket_policy_oai" {
  count    = "${var.enable_oai == true ? 1 : 0}"
  template = file("${path.module}/website_bucket_policy_oai.json")

  vars = {
    bucket  = var.bucket_name
    secret  = var.duplicate-content-penalty-secret
    iam_arn = aws_cloudfront_origin_access_identity.origin_access_identity[count.index]
  }
}

data "template_file" "bucket_policy" {
  template = file("${path.module}/website_bucket_policy.json")

  vars = {
    bucket = var.bucket_name
    secret = var.duplicate-content-penalty-secret
  }
}

locals {
  origin_domain_name     = aws_s3_bucket.website_bucket.website_endpoint
  origin_domain_name_oai = aws_s3_bucket.website_bucket.bucket_regional_domain_name
  origin_access_identity = var.enable_oai == true ? [aws_cloudfront_origin_access_identity.origin_access_identity[0].cloudfront_access_identity_path] : []

  custom_origin_config = var.enable_oai == false ? [{
    origin_protocol_policy = "http-only"
    http_port              = "80"
    https_port             = "443"
    origin_ssl_protocols   = ["TLSv1.2"]
  }] : []
}

resource "aws_s3_bucket" "website_bucket" {
  bucket = var.bucket_name
  policy = var.enable_oai == true ? data.template_file.bucket_policy_oai[0].rendered : data.template_file.bucket_policy.rendered

  versioning {
    enabled = var.versioning
  }

  website {
    index_document = "index.html"
    error_document = "404.html"
    routing_rules  = var.routing_rules
  }


  dynamic "cors_rule" {
    for_each = var.cors_rule_inputs == null ? [] : var.cors_rule_inputs

    content {
      allowed_headers = cors_rule.value.allowed_headers
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      expose_headers  = cors_rule.value.expose_headers
    }
  }

  //  logging {
  //    target_bucket = "${var.log_bucket}"
  //    target_prefix = "${var.log_bucket_prefix}"
  //  }

  tags = {
    project     = var.project
    environment = var.environment
    application = var.application
  }
}

################################################################################################################
## Configure the credentials and access to the bucket for a deployment user
################################################################################################################
data "template_file" "deployer_role_policy_file" {
  template = file("${path.module}/deployer_role_policy.json")

  vars = {
    bucket = var.bucket_name
  }
}

resource "aws_iam_policy" "site_deployer_policy" {
  name        = "${var.bucket_name}.deployer"
  path        = "/"
  description = "Policy allowing to publish a new version of the website to the S3 bucket"
  policy      = data.template_file.deployer_role_policy_file.rendered
}

resource "aws_iam_policy_attachment" "site-deployer-attach-user-policy" {
  name       = "${var.bucket_name}-deployer-policy-attachment"
  users      = [var.deployer]
  policy_arn = aws_iam_policy.site_deployer_policy.arn
}

################################################################################################################
## Create a Cloudfront distribution for the static website
################################################################################################################
resource "aws_cloudfront_distribution" "website_cdn" {
  enabled      = true
  price_class  = var.price_class
  http_version = "http2"

  origin {
    origin_id   = "origin-bucket-${aws_s3_bucket.website_bucket.id}"
    domain_name = var.enable_oai == true ? local.origin_domain_name_oai : local.origin_domain_name

    dynamic "s3_origin_config" {
      for_each = local.origin_access_identity == null ? [] : local.origin_access_identity
      content {
        origin_access_identity = s3_origin_config.value
      }
    }

    dynamic "custom_origin_config" {
      for_each = local.custom_origin_config == null ? [] : local.custom_origin_config
      content {
        origin_protocol_policy = custom_origin_config.value.origin_protocol_policy
        http_port              = custom_origin_config.value.http_port
        https_port             = custom_origin_config.value.https_port
        origin_ssl_protocols   = custom_origin_config.value.origin_ssl_protocols
      }
    }

    custom_header {
      name  = "User-Agent"
      value = var.duplicate-content-penalty-secret
    }
  }

  default_root_object = var.default-root-object

  custom_error_response {
    error_code            = "404"
    error_caching_min_ttl = "360"
    response_code         = "200"
    response_page_path    = var.not-found-response-path
  }

  default_cache_behavior {
    allowed_methods = ["GET", "HEAD", "DELETE", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods  = ["GET", "HEAD"]

    dynamic "lambda_function_association" {
      for_each = var.enable_lambda_sec_headers == null ? [] : var.enable_lambda_sec_headers
      content {
        event_type = lambda_function_association.value.event_type
        lambda_arn = lambda_function_association.value.lambda_arn
      }
    }

    forwarded_values {
      query_string = var.forward-query-string

      cookies {
        forward = "none"
      }
    }

    trusted_signers = var.trusted_signers

    min_ttl          = var.min_ttl
    default_ttl      = var.default_ttl
    max_ttl          = var.max_ttl
    target_origin_id = "origin-bucket-${aws_s3_bucket.website_bucket.id}"

    // This redirects any HTTP request to HTTPS. Security first!
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.acm-certificate-arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2019"
  }

  aliases = var.domain
  tags = {
    project     = var.project
    environment = var.environment
    application = var.application
  }
}

################################################################################################################
## Create Cloudfront OAI
################################################################################################################

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  count   = var.enable_oai == true ? 1 : 0
  comment = "Create OAI to use in CF"
}
