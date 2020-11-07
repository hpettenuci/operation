#!/bin/bash

yum install epel-release -y
yum install jq unzip -y

#aws
INSTANCE_ID="$(curl -s http://169.254.169.254/latest/meta-data/instance-id)"
REGION="$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')"
AWS_ARN="$(curl -s http://169.254.169.254/latest/meta-data/iam/info | jq -r '.InstanceProfileArn' | sed 's/instance-profile/role/g')"

#aws cli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install -b /usr/bin

mkdir -p /root/.aws
echo "[default]
region = ${REGION}" > /root/.aws/config
echo "[profile default]
role_arn = ${AWS_ARN}
source_profile = default" > /root/.aws/credentials
chmod 0600 /root/.aws/*

SCRIPT="null"
COUNT=0
while [ "${SCRIPT}" == "null" ] && [ $COUNT -le 30 ]; do
   SCRIPT="$(aws ec2 describe-tags --filters Name=resource-type,Values=instance Name=resource-id,Values=\"${INSTANCE_ID}\" Name=tag-key,Values=script | jq -r '.Tags[0].Value')"
   echo "SCRIPT=${SCRIPT}"
   sleep 5
done

#iniciar_maquina
cd /tmp
aws s3 cp "s3://versoes-lincros/scripts/${SCRIPT}" .
chmod +x "${SCRIPT}"
./"${SCRIPT}"