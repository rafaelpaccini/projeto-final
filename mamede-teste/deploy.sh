#!/bin/bash
VAR_1="$1"
echo $VAR_1
cd ./mamede-teste
ANSIBLE_OUT=$(ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i hosts provisionar.yml --extra-vars "hosts=$VAR_1" -u ubuntu --private-key /var/lib/jenkins/treinamentoitau_mauricio2.pem)
echo $ANSIBLE_OUT

## Mac ##
# MYSQL_POD_NAME=$(echo $ANSIBLE_OUT | grep -oE "(mysql-.*? )" )
## Linux ##
# MYSQL_POD_NAME=$(echo $ANSIBLE_OUT | grep -oP "(mysql-.*? )" )

echo "Esperando subir os pods ..."
sleep 300

cat <<EOF > restore-dump-mysql.yml
- hosts: 
  - mysql-dev
  become: yes
  tasks:
    - name: "Upload dump"
      copy:
        src: "k8s-deploy/1.2-dump-mysql.sql"
        dest: "/root/"

    - name: "Create dabatase"
      shell: echo "create database SpringWebYoutubeTest;" 
    
    - name: "Restore dump mysql"
      shell: "mysql root -p'root' < /root/1.2-dump-mysql.sql"
EOF

#ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i hosts restore-dump-mysql.yml -u ubuntu --private-key /var/lib/jenkins/treinamentoitau_mauricio2.pem
