## 5.0.18 (October 27, 2020)

IMPROVEMENTS:

 * Add conditional block to add Lambda funtion (Security headers).

## 5.0.11 (October 15, 2020)

IMPROVEMENTS:

 * Add Origin Access Identity and conditional to Cors Rules in S3 bucket.

## 3.0.1 (April 26, 2017)

IMPROVEMENTS:

 * Support for `trusted_signers` on the CloudFront distribution of module `site-main`.

## 3.0.0 (April 19, 2017)

IMPROVEMENTS:

 * `bucket_name` is a required variable for module `site-main`. Bumped the major version as this is a breaking change.

## 2.0.3 (April 18, 2017)

IMPROVEMENTS:

 * Adding the main website bucket arn as an output.

## 2.0.2 (April 18, 2017)

IMPROVEMENTS:

 * Adding the main website bucket id as an output.

## 2.0.1 (April 6, 2017)

IMPROVEMENTS:

 * Added `project` and `environment` variables to `site-main` and `site-redirect` modules
 * Added a general `tags` variable to `site-main` and `site-redirect` modules

## 2.0.0 (October 16, 2016)

IMPROVEMENTS:

 * Upgraded the modules to be compatible with Terraform 0.7.x

## 1.0.0 (October 16, 2016)

FEATURES:
 * Last version compatible with Terraform up to 0.6.x
