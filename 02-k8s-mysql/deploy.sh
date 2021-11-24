#!/bin/bash

# ID_M1_DNS="ubuntu@ec2-18-234-97-123.compute-1.amazonaws.com"
# ID_M1_DNS=$(echo "$ID_M1_DNS" | cut -b 8-)
# echo ${ID_M1_DNS}

#### idéia para buscar itens do debugger do ansible ####
# | grep -oP "(kubeadm join.*?certificate-key.*?)'" | sed 's/\\//g' | sed "s/'//g" | sed "s/'t//g" | sed "s/,//g"

cd 02-k8s-mysql/0-terraform
terraform init
terraform apply -auto-approve

echo  "Aguardando a criação das maquinas ..."
sleep 5

ID_M1=$(terraform output | grep 'mysql-dev -' | awk '{print $4;exit}')
ID_M1_DNS=$(terraform output | grep 'mysql-dev -' | awk '{print $8;exit}' | cut -b 8-)

ID_M2=$(terraform output | grep 'mysql-stage -' | awk '{print $4;exit}')
ID_M2_DNS=$(terraform output | grep 'mysql-stage -' | awk '{print $8;exit}' | cut -b 8-)

ID_M3=$(terraform output | grep 'mysql-prod -' | awk '{print $4;exit}')
ID_M3_DNS=$(terraform output | grep 'mysql-prod -' | awk '{print $8;exit}' | cut -b 8-)


# ID_HAPROXY=$(terraform output | grep 'k8s_proxy -' | awk '{print $3;exit}')
# ID_HAPROXY_DNS=$(terraform output | grep 'k8s_proxy -' | awk '{print $8;exit}' | cut -b 8-)


# ID_W1=$(terraform output | grep 'k8s-workers 1 -' | awk '{print $4;exit}')
# ID_W1_DNS=$(terraform output | grep 'k8s-workers 1 -' | awk '{print $9;exit}' | cut -b 8-)

# ID_W2=$(terraform output | grep 'k8s-workers 2 -' | awk '{print $4;exit}')
# ID_W2_DNS=$(terraform output | grep 'k8s-workers 2 -' | awk '{print $9;exit}' | cut -b 8-)

# ID_W3=$(terraform output | grep 'k8s-workers 3 -' | awk '{print $4;exit}')
# ID_W3_DNS=$(terraform output | grep 'k8s-workers 3 -' | awk '{print $9;exit}' | cut -b 8-)

echo "
[ec2-mysql-dev]
$ID_M1_DNS
[ec2-mysql-stage]
$ID_M2_DNS
[ec2-mysql-prod]
$ID_M3_DNS


" > ../1-ansible/hosts

ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i hosts provisionar.yml -u ubuntu --private-key /var/lib/jenkins/treinamentoitau_mauricio2.pem