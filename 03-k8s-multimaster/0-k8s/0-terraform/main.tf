provider "aws" {
  region = "sa-east-1"
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com" # outra opção "https://ifconfig.me"
}

resource "aws_instance" "k8s_proxy" {
  ami           = "ami-0e66f5495b4efdd0f"
  instance_type = "t2.medium"
  key_name      = "treinamentoitau_mauricio2"
  subnet_id = "subnet-013b710125e49d6a7"
  associate_public_ip_address = true
  root_block_device {
    encrypted = true
    volume_size = 60
  }
  
  tags = {
    Name = "k8s-haproxy"
  }
  vpc_security_group_ids = [aws_security_group.acessos_haproxy.id]
}

resource "aws_instance" "k8s_masters" {
  ami           = "ami-0c31a5eecbfa3af39"
  instance_type = "t2.large"
  key_name      = "treinamentoitau_mauricio2"
  subnet_id = "subnet-013b710125e49d6a7"
  associate_public_ip_address = true
  root_block_device {
    encrypted = true
    volume_size = 60
  }
  count         = 3
  tags = {
    Name = "k8s-master-${count.index}"
  }
  vpc_security_group_ids = [aws_security_group.acessos_masters.id]
  depends_on = [
    aws_instance.k8s_workers,
  ]
}

resource "aws_instance" "k8s_workers" {
  ami           = "ami-0c31a5eecbfa3af39"
  instance_type = "t2.medium"
  key_name      = "treinamentoitau_mauricio2"
  subnet_id = "subnet-013b710125e49d6a7"
  associate_public_ip_address = true
  root_block_device {
    encrypted = true
    volume_size = 60
  }
  count         = 3
  tags = {
    Name = "k8s_workers-${count.index}"
  }
  vpc_security_group_ids = [aws_security_group.acessos_workers.id]
}


resource "aws_security_group" "acessos_masters" {
  name        = "k8s-acessos_masters-projeto-final"
  description = "acessos inbound traffic"
  vpc_id = "vpc-006b099589ba3289e"

  ingress = [
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
    {
      cidr_blocks      = []
      description      = "Libera acesso k8s_masters"
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = true
      to_port          = 0
    },
    {
      cidr_blocks      = []
      description      = "Libera acesso k8s_haproxy"
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = [
        "${aws_security_group.acessos_haproxy.id}",
      ]
      self             = false
      to_port          = 0
    },
    # {
    #   cidr_blocks      = []
    #   description      = "Libera acesso k8s_workers"
    #   from_port        = 0
    #   ipv6_cidr_blocks = []
    #   prefix_list_ids  = []
    #   protocol         = "-1"
    #   security_groups  = [
    #     "${aws_security_group.acessos_workers.id}",
    #     //aws_security_group.acessos_masters.id
    #   ]
    #   self             = false
    #   to_port          = 0
    # },
    {
      cidr_blocks      = [
        "0.0.0.0/0",
      ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 65535
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
    Name = "allow_ssh"
  }
}

resource "aws_security_group" "acessos_haproxy" {
  name        = "k8s-haproxy-projeto-final"
  description = "acessos inbound traffic"
  vpc_id = "vpc-006b099589ba3289e"

  ingress = [
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
    {
      cidr_blocks      = []
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = [
        # aws_security_group.acessos_masters.id,
        "sg-093008c8bd28b70c3",
      ]
      self             = false
      to_port          = 0
    },
    {
      cidr_blocks      = []
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = [
        # aws_security_group.acessos_workers.id
        "sg-070d67148a6770f4e",
      ]
      self             = false
      to_port          = 0
    },
    {
      cidr_blocks      = []
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = true
      to_port          = 65535
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
    Name = "allow_haproxy_ssh"
  }
}

resource "aws_security_group" "acessos_workers" {
  name        = "k8s-workers-projeto-final"
  description = "acessos inbound traffic"
  vpc_id = "vpc-006b099589ba3289e"

  ingress = [
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
    {
      cidr_blocks      = []
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = [
        aws_security_group.acessos_masters.id,
      ]
      self             = false
      to_port          = 0
    },
    {
      cidr_blocks      = []
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = true
      to_port          = 65535
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
    Name = "allow_ssh"
  }
}

output "k8s-masters" {
  value = [
    for key, item in aws_instance.k8s_masters :
      "k8s-master ${key+1} - ${item.private_ip} - ssh -i /var/lib/jenkins/treinamentoitau_mauricio2.pem ubuntu@${item.public_dns} -o ServerAliveInterval=60"
  ]
}

output "output-k8s_workers" {
  value = [
    for key, item in aws_instance.k8s_workers :
      "k8s-workers ${key+1} - ${item.private_ip} - ssh -i /var/lib/jenkins/treinamentoitau_mauricio2.pem ubuntu@${item.public_dns} -o ServerAliveInterval=60"
  ]
}

output "output-k8s_proxym" {
  value = [
    "k8s_proxy - ${aws_instance.k8s_proxy.private_ip} - ssh -i /var/lib/jenkins/treinamentoitau_mauricio2.pem ubuntu@${aws_instance.k8s_proxy.public_dns} -o ServerAliveInterval=60"
  ]
}

# output "security-group-workers-e-haproxy" { 
#   value =  aws_security_group.acessos_haproxy.id

# }

output "security-group-workers" { 
  value =  aws_security_group.acessos_workers.id

}



output "security-group-masters" { 
  value =  aws_security_group.acessos_masters.id

}

# terraform refresh para mostrar o ssh