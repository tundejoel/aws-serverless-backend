# Read the existing hosted zone (owned by the portfolio repo's Terraform)
data "aws_route53_zone" "main" {
  name = "adedayoafolabi.com"
}

# Tell SES: I own this domain
resource "aws_sesv2_email_identity" "domain" {
  email_identity = "adedayoafolabi.com"
}

# Publish the three DKIM tokens SES hands back
resource "aws_route53_record" "ses_dkim" {
  count   = 3
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "${aws_sesv2_email_identity.domain.dkim_signing_attributes[0].tokens[count.index]}._domainkey.adedayoafolabi.com"
  type    = "CNAME"
  ttl     = 600
  records = ["${aws_sesv2_email_identity.domain.dkim_signing_attributes[0].tokens[count.index]}.dkim.amazonses.com"]
}