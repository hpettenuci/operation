#!/bin/bash

cd /tmp
wget https://raw.githubusercontent.com/rabbitmq/rabbitmq-management/v3.8.9/bin/rabbitmqadmin -o rabbitmqadmin
rm rabbitmqadmin
mv rabbitmqadmin.1 rabbitmqadmin
cp rabbitmqadmin /usr/local/bin/
chmod +x /usr/local/bin/rabbitmqadmin