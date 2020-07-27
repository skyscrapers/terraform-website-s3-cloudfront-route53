################################################################################################################
## Create a Route53 CNAME record to the Cloudfront distribution
################################################################################################################
resource "aws_route53_record" "cdn-cname" {

  count   = "${length(var.domain)}"
  zone_id = var.route53_zone_id
  name    = "${element(var.domain, count.index)}"
  type    = "CNAME"
  ttl     = "300"
  records = [var.target]
  
}
