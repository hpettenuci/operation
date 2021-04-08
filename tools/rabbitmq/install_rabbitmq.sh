#!/bin/bash

# Configure Rabbit repository
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | sudo bash

# Install RabbitMQ
yum makecache -y --disablerepo='*' --enablerepo='rabbitmq_rabbitmq-server'
yum -y install rabbitmq-server

# Enable Rabbit service
systemctl enable --now rabbitmq-server.service
systemctl status rabbitmq-server

# Enable Web dashboard
rabbitmq-plugins enable rabbitmq_management

# Set firewall rules
firewall-cmd --add-port={5672,15672}/tcp --permanent
firewall-cmd --reload