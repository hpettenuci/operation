#!/bin/bash

yum install epel-release git python38 python38-pip yum-utils -y
yum install tmux iotop htop jq nano unzip httpd-tools -y

#aws cli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install -b /usr/bin

# Configure Consul repository
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo

# Install MongoDB
yum -y install consul

echo "UUID=$(blkid -s UUID -o value /dev/sdb1) /mnt/dados xfs defaults 0 0" >> /etc/fstab
mkdir -p /mnt/dados
mount /mnt/dados

# Set firewall rules
firewall-cmd --add-port={8300,8500}/tcp --permanent
firewall-cmd --reload

# https://learn.hashicorp.com/tutorials/consul/deployment-guide