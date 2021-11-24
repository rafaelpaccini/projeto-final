#!/bin/bash
cd 01-k8s/0-terraform

uri=$(terraform output | grep public_ip | awk '{print $2;exit}' | sed -e "s/\",//g")

echo $uri

body=$(curl "http://$uri")

regex='Welcome to nginx!'

if [[ $body =~ $regex ]]
then 
    echo "::::: nginx está no ar :::::"
    exit 0
else
    echo "::::: nginx não está no ar :::::"
    exit 1
fi