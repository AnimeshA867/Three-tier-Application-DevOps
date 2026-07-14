resource "aws_db_subnet_group" "rds" {
  name       = "${var.env}-rds-subnet-group"
  subnet_ids = var.data_subnet_ids
}

resource "aws_db_instance" "postgres" {
  identifier             = "${var.env}-postgres-db"
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "15.4"
  instance_class         = "db.t3.micro"
  db_name                = "appdb"
  username               = "dbadmin"
  password               = "ChangePassword123!@#"
  db_subnet_group_name   = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [var.rds_sg_id]
  multi_az               = true
  skip_final_snapshot    = true

}

# Cache layer (Elasticache Redis)

resource "aws_elasticache_subnet_group" "redis" {
  name       = "${var.env}-redis-subnet-group"
  subnet_ids = var.data_subnet_ids
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "${var.env}-redis"
  engine               = "redis"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.redis.name
  security_group_ids   = [var.redis_sg_id]
}
