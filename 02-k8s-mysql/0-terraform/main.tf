provider "aws" {
  region = "sa-east-1"
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com" # outra opção "https://ifconfig.me"
}

resource "aws_instance" "mysql-dev" {
  ami           = "ami-0e66f5495b4efdd0f"
  instance_type = "t2.medium"
  key_name      = "treinamentoitau_mauricio2"
  subnet_id = "subnet-06445727840016fb0"
  root_block_device {
    encrypted = true
    volume_size = 8
  }
  
  tags = {
    Name = "mysql-dev-projeto-final"
  }
  vpc_security_group_ids = [aws_security_group.acesso_sql_server.id]
}


resource "aws_instance" "mysql-stage" {
  ami           = "ami-0e66f5495b4efdd0f"
  instance_type = "t2.medium"
  key_name      = "treinamentoitau_mauricio2"
  subnet_id = "subnet-06445727840016fb0"
  root_block_device {
    encrypted = true
    volume_size = 8
  }
  
  tags = {
    Name = "mysql-stage-projeto-final"
  }
  vpc_security_group_ids = [aws_security_group.acesso_sql_server.id]
}

resource "aws_instance" "mysql-prod" {
  ami           = "ami-0e66f5495b4efdd0f"
  instance_type = "t2.medium"
  key_name      = "treinamentoitau_mauricio2"
  subnet_id = "subnet-06445727840016fb0"
  root_block_device {
    encrypted = true
    volume_size = 8
  }
  
  tags = {
    Name = "mysql-prod-projeto-final"
  }
  vpc_security_group_ids = [aws_security_group.acesso_sql_server.id]
}

resource "aws_security_group" "acesso_sql_server" {
  name        = "acesso_sql_server"
  description = "Habilita porta padrao mysql"
  vpc_id = "vpc-006b099589ba3289e"
  ingress = [
    {
      description      = "Porta padrao acesso_sql_server"
      from_port        = 3306
      to_port          = 3306
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids = null,
      security_groups: null,
      self: null
    },
    {
      description      = "SSH from VPC"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids = null,
      security_groups: null,
      self: null
    },
  ]
egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = [],
      prefix_list_ids = null,
      security_groups: null,
      self: null,
      description: "Libera dados da rede interna"
    }
  ]

  tags = {
    Name = "acesso_mysql_server"
  }
}

output "mysql" {
  value = [
    aws_instance.mysql-dev.private_ip, 
    aws_instance.mysql-stage.private_ip,
    aws_instance.mysql-prod.private_ip,
    
  ]
}

output "mysql-dev-projeto-final" {
  value = [
       "mysql-dev - ${aws_instance.mysql-dev.private_ip} - ssh -i ~/.ssh/treinamentoitau_mauricio2.pem ubuntu@${aws_instance.mysql-dev.private_ip} -o ServerAliveInterval=60",
       "mysql-stage - ${aws_instance.mysql-stage.private_ip} - ssh -i ~/.ssh/treinamentoitau_mauricio2.pem ubuntu@${aws_instance.mysql-stage.private_ip} -o ServerAliveInterval=60",
       "mysql-prod - ${aws_instance.mysql-prod.private_ip} - ssh -i ~/.ssh/treinamentoitau_mauricio2.pem ubuntu@${aws_instance.mysql-prod.private_ip} -o ServerAliveInterval=60"
  ]

}

# terraform refresh para mostrar o ssh