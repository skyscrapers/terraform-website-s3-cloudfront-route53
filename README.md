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
    }

Mention the double slash. This is to indicate to look into the subdirectory within the Github repository.
See the [Terraform Modules documentation](https://www.terraform.io/docs/modules/sources.html#github) for more info.

## Setting up the redirect site

## Setting up the Route 53 CNAME

Whether it is a main site or a redirect site, a CNAME DNS record is needed for your site to be accessed on a 
non-root domain.

    module "site-main" {
       source = "github.com/ringods/terraform-website-s3-cloudfront-route53//r53-cname"
    }

## Setting up the Route 53 ALIAS

Whether it is a main site or a redirect site, an ALIAS DNS record is needed for your site to be accessed on a 
root domain.

    module "site-main" {
       source = "github.com/ringods/terraform-website-s3-cloudfront-route53//r53-alias"
    }
