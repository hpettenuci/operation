#!/bin/bash

yum install epel-release git python38 python38-pip -y
yum install tmux iotop htop jq nano unzip httpd-tools -y

#aws cli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install -b /usr/bin

# Configure MongoDB repository
echo '
[mongodb-org-4.4]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/4.4/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-4.4.asc' > /etc/yum.repos.d/mongodb-org-4.4.repo

# Install MongoDB
yum install -y mongodb-org

echo "UUID=$(blkid -s UUID -o value /dev/sdb1) /mnt/dados xfs defaults 0 0" >> /etc/fstab
mkdir -p /mnt/dados
mount /mnt/dados

rm -f /var/lib/mongo
ln -s /mnt/dados /var/lib/mongo 

chown -R mongod:mongod /var/lib/mongo

# Enable Rabbit service
systemctl enable --now mongod

# Set firewall rules
firewall-cmd --add-port=27017/tcp --permanent
firewall-cmd --reload