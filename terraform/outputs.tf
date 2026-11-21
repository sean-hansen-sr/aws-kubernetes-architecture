output "backend_nlb_dns_name" {
  description = "The internal DNS name of the backend Network Load Balancer"
  value       = aws_lb.backend_nlb.dns_name
}

output "backend_nlb_endpoint" {
  description = "The full TCP endpoint with port 30080 for services in Private Subnet 1"
  value       = "${aws_lb.backend_nlb.dns_name}:30080"
}

output "frontend_nlb_dns_name" {
  value = aws_lb.frontend_nlb.dns_name
}

output "kb_docs_bucket_name" {
  description = "The name of the S3 knowledge base docs bucket"
  value       = aws_s3_bucket.s3_kb_docs.id
}