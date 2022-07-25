# ------------------------------------------------------------------------------
# DNS records that support the CloudFront endpoints and application.
# ------------------------------------------------------------------------------

resource "aws_route53_record" "rules_vm_A" {
  provider = aws.route53resourcechange

  alias {
    evaluate_target_health = false
    name                   = aws_cloudfront_distribution.rules_s3_distribution.domain_name
    zone_id                = local.cloudfront_zone_id
  }
  name    = var.domain
  type    = "A"
  zone_id = data.terraform_remote_state.dns_cyber_dhs_gov.outputs.cyber_dhs_gov_zone.id
}

resource "aws_route53_record" "rules_vm_AAAA" {
  provider = aws.route53resourcechange

  alias {
    evaluate_target_health = false
    name                   = aws_cloudfront_distribution.rules_s3_distribution.domain_name
    zone_id                = local.cloudfront_zone_id
  }
  name    = var.domain
  type    = "AAAA"
  zone_id = data.terraform_remote_state.dns_cyber_dhs_gov.outputs.cyber_dhs_gov_zone.id
}
