# Terraform setup for S3 static site with CloudFront, Certificate Manager and Route53

This Git repository contains the required [Terraform](https://www.terraform.io/)
scripts to setup a static website, hosted out of an S3 bucket.
The site is fronted by a CloudFront distribution, uses AWS Certificate Manager for HTTPS and allows
for configuring the required DNS entries in Route53.

The scripts also take care of:
* Preventing the origin bucket being indexed by search bots.
* Redirect other domains to the main site with proper rewriting.
* Access logging
* Redirect HTTP to HTTPS

These scripts suite my needs, but all evolution in the form of pull requests are welcome! To make
this process fluent, create [an issue](https://github.com/ringods/terraform-website-s3-cloudfront-route53/issues)
first describing what you want to contribute, then fork and create a branch with a clear name.
Submit your work as a pull request.

## Introduction

This repository is split in 4 parts, each of which can be used as a separate module in your own root script.
The split is done because of the lack of conditional logic in Terraform 0.6.x. I leave the composition
of the required setup to you, the user.

* *site-main*: setup of the main S3 bucket with a CloudFront distribution
* *site-redirect*: setup of the redirect S3 bucket with a CloudFront distribution
* *r53-cname*: configuration of a Route53 CNAME record pointing to a CloudFront distribution
* *r53-alias*: configuraiton of a Route53 ALIAS record pointing to a CloudFront distribution. Required
  for naked domain (APEX) setups.

With the above 4 modules, you can pick yourself what you need for setups like:

* single site on https://sub.domain.com
* single site on https://domain.com
* main site on https://www.domain.com and redirecting the naked domain to the www version.
* main site on https://domain.com and redirecting the www version to the naked domain.

Given the ease of setting up SSL secured sites with AWS Certificate Manager, the above modules do not offer
the option to set up non-SSL sites. But since AWS Certificate Manager requires manual intervention to
complete the certificate setup, you must create your certificates first before using the modules below.

_Note:_ AWS Certificate Manager supports multiple regions. To use CloudFront with ACM certificates, the
certificates must be requested in region us-east-1.

## Configuring Terraform

The different modules do not define variables for the AWS provider. For ease of use, the configuration
is done implicitly by setting the following environment variables:

* `AWS_SECRET_ACCESS_KEY`
* `AWS_ACCESS_KEY_ID`
* `AWS_DEFAULT_REGION`

These variables are inherited by any Terraform modules and prevents passing too much TF variables
from parent to module. This info was found
[here](https://groups.google.com/d/msg/terraform-tool/GM1QisZ95qc/Pt8JqPVePHAJ).

## Setting up the main site

Creating all the resources for an S3 based static website, with a CloudFront distribution and using
the appropriate SSL certificates is as easy as using the `site-main` module and passing the
appropriate variables:

    module "site-main" {
       source = "github.com/ringods/terraform-website-s3-cloudfront-route53//site-main"

       region = "eu-west-1"
       domain = "my.domain.com"
       bucket_name = "site_mydomain"
       duplicate-content-penalty-secret = "some-secret-password"
       deployer = "an-iam-username"
       acm-certificate-arn = "arn:aws:acm:us-east-1:<id>:certificate/<cert-id>"
       not-found-response-path = "/404.html"
    }

Mention the double slash. This is to indicate to look into the subdirectory within the Github repository.
See the [Terraform Modules documentation](https://www.terraform.io/docs/modules/sources.html#github) for more info.

### Inputs

* `region`: the AWS region where the S3 bucket will be created. The source bucket can be created in any
   of the available regions. The default value is `us-east-1`.
* `domain`: the domain name by which you want to make the website available on the Internet. While we are not
  at the point of setting up the DNS part, the CloudFront distribution needs to know for which domain it needs
  to accept requests.
* `bucket_name`: the name of the bucket to create for the S3 based static website.
* `duplicate-content-penalty-secret`: Value that will be used in a custom header for a CloudFront distribution
  to gain access to the origin S3 bucket. If you make an S3 bucket available as the source for a CloudFront
  distribution, you have the risk of search bots to index both this source bucket and the distribution.
  Google _punishes_ you for this as you can read in
  [this article](https://support.google.com/webmasters/answer/66359?hl=en). We need to protect access to
  the source bucket. There are 2 options to prevent this: using an Origin Access User between CloudFront
  distribution and the source S3 bucket, or using custom headers between the distribution and the bucket.
  The use of an Origin Access User prescribes accessing the source bucket in REST mode which results in
  bucket redirects not being followed. As a result, this module will use the custom header option.
* `deployer`: the name of an existing IAM user that will be used to push contents to the S3 bucket. This
  user will get a role policy attached to it, configured to have read/write access to the bucket that
  will be created.
* `acm-certificate-arn`: the id of an certificate in AWS Certificate Manager. As this certificate will be
  used on a CloudFront distribution, Amazon's documentation states the certificate must be generated
  in the `us-east-1` region.
* `not-found-response-path`: response path for the file that should be served on 404. Default to `/404.html`,
  but can be e.x. `/index.html` for single page applications.
* `trusted_signers`: (Optional) List of AWS account IDs that are allowed to create signed URLs for this
  distribution. May contain `self` to indicate the account where the distribution is created in.
* `project`: (Optional) the name of a project this site belongs to. Default value = `noproject`
* `environment`: (Optional) the environment this site belongs to. Default value = `default`
* `tags`: (Optional) Additional key/value pairs to set as tags.
* `forward-query-string`:  (Optional) Forward the query string to the origin. Default value = `false`

### Outputs

* `website_cdn_hostname`: the Amazon generated Cloudfront domain name. You can already test accessing your
  website content by this hostname. This hostname is needed later on to create a `CNAME` record in Route53.
* `website_cdn_zone_id`: the Hosted Zone ID of the Cloudfront distribution. This zone ID is needed
  later on to create a Route53 `ALIAS` record.
* `website_bucket_id`: The website bucket id
* `website_bucket_arn`: The website bucket arn
* `website_cdn_id`: The CDN ID of the Cloudfront distribution.
* `website_cdn_arn`: The ARN of the CDN

## Setting up the redirect site

    module "site-redirect" {
       source = "github.com/ringods/terraform-website-s3-cloudfront-route53//site-redirect"

       region = "eu-west-1"
       domain = "my.domain.com"
       duplicate-content-penalty-secret = "some-secret-password"
       deployer = "an-iam-username"
       acm-certificate-arn = "arn:aws:acm:us-east-1:<id>:certificate/<cert-id>"
    }

### Inputs

* `project`: (Optional) the name of a project this site belongs to. Default value = `noproject`
* `environment`: (Optional) the environment this site belongs to. Default value = `default`
* `tags`: (Optional) Additional key/value pairs to set as tags.


### Outputs

* `website_cdn_hostname`: the Amazon generated Cloudfront domain name. You can already test accessing your
  website content by this hostname. This hostname is needed later on to create a `CNAME` record in Route53.
* `website_cdn_zone_id`: the Hosted Zone ID of the Cloudfront distribution. This zone ID is needed
  later on to create a Route53 `ALIAS` record.

## Setting up the Route 53 CNAME

Whether it is a main site or a redirect site, a CNAME DNS record is needed for your site to be accessed on a
non-root domain.

    module "dns-cname" {
       source = "github.com/ringods/terraform-website-s3-cloudfront-route53//r53-cname"

       domain = "my.domain.com"
       target = "${module.site-main.website_cdn_hostname}"
       route53_zone_id = "<r53-zone-id>"
    }

### Inputs

* `domain`: the domain name you want to use to access your static website. This should match the domain
  name used in setting up either a main or a redirect site.
* `target`: the domain name of the CloudFront distribution to which the domain name should point. You
  usually pass the `website_cdn_hostname` output variable from the main or redirect site here.
* `route53_zone_id`: the Route53 Zone ID where the CNAME entry must be created.

## Setting up the Route 53 ALIAS

Whether it is a main site or a redirect site, an ALIAS DNS record is needed for your site to be accessed on a
root domain.

    module "dns-alias" {
       source = "github.com/ringods/terraform-website-s3-cloudfront-route53//r53-alias"

       domain = "domain.com"
       target = "${module.site-main.website_cdn_hostname}"
       cdn_hosted_zone_id = "${module.site-main.website_cdn_zone_id}"
       route53_zone_id = "<r53-zone-id>"
    }

### Inputs

* `domain`: the domain name you want to use to access your static website. This should match the domain
  name used in setting up either a main or a redirect site.
* `target`: the domain name of the CloudFront distribution to which the domain name should point. You
  usually pass the `website_cdn_hostname` output variable from the main or redirect site here.
* `cdn_hosted_zone_id`: the Hosted Zone ID of the CloudFront distribution. You usually pass the
  `website_cdn_zone_id` output variable from the main or redirect site here.
* `route53_zone_id`: the Route53 Zone ID where the CNAME entry must be created.

## Users

If you are using the modules in this Git repository to set up your static site and you want some
visibility, add your site and info below and submit a pull request:

* [Ringo De Smet's Blog](https://ringo.de-smet.name) (Ringo De Smet)
* [ReleaseQueue](https://releasequeue.com) (Ringo De Smet)

**Enjoy!**
