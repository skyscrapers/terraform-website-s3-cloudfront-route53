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

################################################################################################################
## Configure the AWS provider for the specific region
################################################################################################################
provider "aws" {
  alias  = "${var.region}"
  region = "${var.region}"
}

################################################################################################################
## Configure the bucket and static website hosting
################################################################################################################
data "template_file" "bucket_policy" {
  template = "${file("${path.module}/website_bucket_policy.json")}"

  vars {
    bucket = "${var.bucket_name}"
    secret = "${var.duplicate-content-penalty-secret}"
  }
}

resource "aws_s3_bucket" "website_bucket" {
  provider = "aws.${var.region}"
  bucket   = "${var.bucket_name}"
  policy   = "${data.template_file.bucket_policy.rendered}"

  website {
    index_document = "index.html"
    error_document = "404.html"
    routing_rules  = "${var.routing_rules}"
  }

  //  logging {
  //    target_bucket = "${var.log_bucket}"
  //    target_prefix = "${var.log_bucket_prefix}"
  //  }

  tags = "${merge("${var.tags}",map("Name", "${var.project}-${var.environment}-${var.domain}", "Environment", "${var.environment}", "Project", "${var.project}"))}"
}

################################################################################################################
## Configure the credentials and access to the bucket for a deployment user
################################################################################################################
data "template_file" "deployer_role_policy_file" {
  template = "${file("${path.module}/deployer_role_policy.json")}"

  vars {
    bucket = "${var.bucket_name}"
  }
}

resource "aws_iam_policy" "site_deployer_policy" {
  provider    = "aws.${var.region}"
  name        = "${var.bucket_name}.deployer"
  path        = "/"
  description = "Policy allowing to publish a new version of the website to the S3 bucket"
  policy      = "${data.template_file.deployer_role_policy_file.rendered}"
}

resource "aws_iam_policy_attachment" "site-deployer-attach-user-policy" {
  provider   = "aws.${var.region}"
  name       = "${var.bucket_name}-deployer-policy-attachment"
  users      = ["${var.deployer}"]
  policy_arn = "${aws_iam_policy.site_deployer_policy.arn}"
}

################################################################################################################
## Create a Cloudfront distribution for the static website
################################################################################################################
resource "aws_cloudfront_distribution" "website_cdn" {
  enabled      = true
  price_class  = "PriceClass_200"
  http_version = "http1.1"

  "origin" {
    origin_id   = "origin-bucket-${aws_s3_bucket.website_bucket.id}"
    domain_name = "${aws_s3_bucket.website_bucket.website_endpoint}"

    custom_origin_config {
      origin_protocol_policy = "http-only"
      http_port              = "80"
      https_port             = "443"
      origin_ssl_protocols   = ["TLSv1"]
    }

    custom_header {
      name  = "User-Agent"
      value = "${var.duplicate-content-penalty-secret}"
    }
  }

  default_root_object = "index.html"

  custom_error_response {
    error_code            = "404"
    error_caching_min_ttl = "360"
    response_code         = "200"
    response_page_path    = "${var.not-found-response-path}"
  }

  "default_cache_behavior" {
    allowed_methods = ["GET", "HEAD", "DELETE", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods  = ["GET", "HEAD"]

    "forwarded_values" {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    trusted_signers = ["${var.trusted_signers}"]

    min_ttl          = "0"
    default_ttl      = "300"                                              //3600
    max_ttl          = "1200"                                             //86400
    target_origin_id = "origin-bucket-${aws_s3_bucket.website_bucket.id}"

    // This redirects any HTTP request to HTTPS. Security first!
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
  }

  "restrictions" {
    "geo_restriction" {
      restriction_type = "none"
    }
  }

  "viewer_certificate" {
    acm_certificate_arn      = "${var.acm-certificate-arn}"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1"
  }

  aliases = ["${var.domain}"]

  tags = "${merge("${var.tags}",map("Name", "${var.project}-${var.environment}-${var.domain}", "Environment", "${var.environment}", "Project", "${var.project}"))}"
}
