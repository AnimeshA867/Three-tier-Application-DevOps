output "alb_sg_id" { value = aws_security_group.alb.id }
output "web_sg_id" { value = aws_security_group.web.id }
output "backend_sg_id" { value = aws_security_group.backend.id }

output "redis_sg_id" { value = aws_security_group.redis.id }

output "rds_sg_id" { value = aws_security_group.database.id }

