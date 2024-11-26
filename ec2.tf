resource "tls_private_key" "key_aws" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "key_pair" {
  key_name   = "my-new-ec2-key"
  public_key = tls_private_key.key_aws.public_key_openssh
}

resource "aws_instance" "new_instance_ec2" {
  ami           = "ami-0866a3c8686eaeeba"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.key_pair.key_name
  subnet_id     = aws_subnet.public_a.id
  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.api_access.id]

  tags = {
    Name = "my-new-ec2"
  }

  user_data = <<-EOF
      #!/bin/bash
      set -e  # Terminate script if any command fails
      sudo apt-get update -y
      curl -fsSL https://get.docker.com -o get-docker.sh
      sudo sh get-docker.sh
      sudo usermod -aG docker ubuntu
      sudo systemctl enable docker
      sudo systemctl start docker

      # Install Docker Compose
      sudo curl -L "https://github.com/docker/compose/releases/download/$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -oP '(?<="tag_name": ")[^"]*')/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
      sudo chmod +x /usr/local/bin/docker-compose

      echo "Docker and Docker Compose installation completed" > /home/ubuntu/docker_installation.log
  EOF
}

output "private_key_pem" {
  value     = tls_private_key.key_aws.private_key_pem
  sensitive = true
}