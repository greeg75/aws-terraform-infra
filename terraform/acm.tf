# Reuse the existing validated ACM certificate
data "aws_acm_certificate" "app" {
  domain      = "api.aws-cloud-lab.fr"
  statuses    = ["ISSUED"]
  most_recent = true
}