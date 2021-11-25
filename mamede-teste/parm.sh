#!/bin/bash

VAR_1="$1"
# $1 se refere ao primeiro parâmetro passado na command line

# TESTE
echo "variável 1: $VAR_1"

cd ./mamede-teste
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i hostsvar teste.yml --extra-vars "hosts=$VAR_1" -u ubuntu --private-key /var/lib/jenkins/treinamentoitau_mauricio2.pem