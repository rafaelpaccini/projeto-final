provider "aws" {
  region = "sa-east-1"
}


resource "aws_instance" "jenkins-projeto-final" {
  subnet_id                   = "subnet-013b710125e49d6a7"
  ami                         = "ami-0e66f5495b4efdd0f"
  instance_type               = "t2.large"
  associate_public_ip_address = true
  root_block_device {
    encrypted   = true
    volume_size = 60
  }
  key_name = "treinamentoitau_mauricio2"
  tags = {
    Name = "jenkins-projeto-final"
  }
  vpc_security_group_ids = ["${aws_security_group.secgroup-jenkins-projeto-final.id}"]
}

resource "aws_security_group" "secgroup-jenkins-projeto-final" {
  name        = "acessos_jenkins-projeto-final"
  description = "acessos_jenkins inbound traffic"
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
    {
      description      = "SSH from VPC"
      from_port        = 8080
      to_port          = 8080
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = null,
      security_groups : null,
      self : null
    },
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
    Name = "projeto-jenkins-secgrp"
  }
}

# terraform refresh para mostrar o ssh
output "jenkins" {
  value = [
    "jenkins",
    "id: ${aws_instance.jenkins-projeto-final.id}",
    "private: ${aws_instance.jenkins-projeto-final.private_ip}",
    "public: ${aws_instance.jenkins-projeto-final.public_ip}",
    "public_dns: ${aws_instance.jenkins-projeto-final.public_dns}",
    "ssh -i ~/.ssh/treinamentoitau_mauricio2.pem ubuntu@${aws_instance.jenkins-projeto-final.public_dns}"
  ]
}

#
