resource "aws_db_subnet_group" "my_db_subnet_group" {
  name       = "my-db-subnet-group"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_db_instance" "my_mysql_instance" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0.32"
  instance_class       = "db.t3.micro"
  username             = "nikao"
  password             = "laravelnew"
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.my_db_subnet_group.name

  vpc_security_group_ids = [aws_security_group.new_api_access.id]

  tags = {
    Name = "MySQL-RDS"
  }
}