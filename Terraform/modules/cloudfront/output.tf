output "web_cdn_domain_name" { value = aws_cloudfront_distribution.web_cdn.domain_name }

output "web_cdn_zone_id" { value = aws_cloudfront_distribution.web_cdn.hosted_zone_id }
