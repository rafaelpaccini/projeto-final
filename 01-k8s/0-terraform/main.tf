provider "aws" {
  region = "sa-east-1"
}

# data "http" "myip" {
#   url = "http://ipv4.icanhazip.com" # outra opção "https://ifconfig.me"
# }

resource "aws_instance" "img-k8s-projeto-final" {
  ami           = "ami-0e66f5495b4efdd0f"
  instance_type = "t2.large"
  key_name      = "treinamentoitau_mauricio2"
  subnet_id                   = "subnet-013b710125e49d6a7"
  associate_public_ip_address = true
  root_block_device {
    encrypted   = true
    volume_size = 60
  }

  tags = {
    Name = "img-k8s-projeto-final"
  }
  vpc_security_group_ids = [aws_security_group.acesso-k8s-projeto-final.id]
}

resource "aws_security_group" "acesso-k8s-projeto-final" {
  name        = "acesso_jenkins_dev_img"
  description = "acesso_jenkins_dev_img inbound traffic"
  vpc_id      = "vpc-006b099589ba3289e"

  ingress = [
    {
      description      = "SSH from VPC"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = null,
      security_groups : null,
      self : null
    },
    # {
    #   description      = "SSH from VPC"
    #   from_port        = 80
    #   to_port          = 80
    #   protocol         = "tcp"
    #   cidr_blocks      = ["0.0.0.0/0"]
    #   ipv6_cidr_blocks = ["::/0"]
    #   prefix_list_ids  = null,
    #   security_groups : null,
    #   self : null
    # },
  ]

  egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"],
      prefix_list_ids  = null,
      security_groups : null,
      self : null,
      description : "Libera dados da rede interna"
    }
  ]

  tags = {
    Name = "secgrp-img-k8s-projeto-final"
  }
}

# terraform refresh para mostrar o ssh
output "img-k8s-projeto-final" {
  value = [
    "resource_id: ${aws_instance.img-k8s-projeto-final.id}",
    "public_ip: ${aws_instance.img-k8s-projeto-final.public_ip}",
    "public_dns: ${aws_instance.img-k8s-projeto-final.public_dns}",
    "ssh -i /var/lib/jenkins/treinamentoitau_mauricio2.pem ubuntu@${aws_instance.img-k8s-projeto-final.public_dns}"
  ]
}