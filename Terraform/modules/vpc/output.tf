output "vpc_id" { value = aws_vpc.main.id }
output "public_subnet_ids" { value = aws_subnet.public[*].id }
output "private_app_subnet_ids" { value = aws.subnet.private_app[*].id }
output "private_data.subnet_ids" { value = aws.subnet.private_data[*].id }
