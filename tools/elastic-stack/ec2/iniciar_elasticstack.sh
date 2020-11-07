#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

yum update -y
yum install epel-release git python-pip -y
yum install tmux iotop htop jq nano unzip httpd-tools -y

#fuso horário
echo "ZONE=\"America/Sao_Paulo\"
UTC=true" > /etc/sysconfig/clock
ln -f -s /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime

#amazon spot
INSTANCE_ID="$(curl -s http://169.254.169.254/latest/meta-data/instance-id)"
PRIVATE_IP="$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"
PUBLIC_IP="$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"
REGION="$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')"
AWS_ARN="$(curl -s http://169.254.169.254/latest/meta-data/iam/info | jq -r '.InstanceProfileArn' | sed 's/instance-profile/role/g')"

DNS_NAME="domain.com"
INSTANCE_NAME="$(aws ec2 describe-tags --filters Name=resource-type,Values=instance Name=resource-id,Values=\"${INSTANCE_ID}\" Name=tag-key,Values=Name | jq -r '.Tags[0].Value')"

RUNNING_INSTANCES=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=${INSTANCE_NAME}*" "Name=instance-state-name,Values=running" | jq -r ".Reservations[].Instances[].Tags[].Value" | grep $INSTANCE_NAME[0-9] | tr '\n')
COUNTER_NAME=1
for SPOT in $RUNNING_INSTANCES; do
    if [ "${COUNTER_NAME}" = "${SPOT}" ]; then
        let COUNTER_NAME=$COUNTER_NAME+1
    else
        break
    fi
done

SPOT_NAME="${INSTANCE_NAME}${COUNTER_NAME}"
aws ec2 create-tags --resources $INSTANCE_ID --tags "Key=Name,Value=${SPOT_NAME}"

#docker
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install docker-ce docker-ce-cli containerd.io -y
curl -L "https://github.com/docker/compose/releases/download/1.25.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/sbin/docker-compose
chmod +x /usr/sbin/docker-compose

ln -s /usr/libexec/docker/docker-runc-current /usr/libexec/docker/docker-runc 

VOLUME_DOCKER_CONFIG="$(aws ec2 describe-volumes --filters Name=tag-key,Values=Name Name=tag-value,Values=\"${INSTANCE_NAME}-config\" Name=status,Values=available | jq -r '.Volumes[0].VolumeId')"
aws ec2 attach-volume --volume-id "${VOLUME_DOCKER_CONFIG}" --instance-id "${INSTANCE_ID}" --device /dev/xvdb
sleep 10

if [ -b "/dev/nvme0n1" ]; then
    echo "UUID=$(blkid -s UUID -o value /dev/nvme1n1p1) /mnt/config xfs defaults 0 0" >> /etc/fstab
elif [ -b "/dev/xvda" ]; then
    echo "UUID=$(blkid -s UUID -o value /dev/xvdb1) /mnt/config xfs defaults 0 0" >> /etc/fstab
else
    echo "UUID=$(blkid -s UUID -o value /dev/sdb1) /mnt/config xfs defaults 0 0" >> /etc/fstab
fi
mkdir -p /mnt/config
mount /mnt/config

VOLUME_DOCKER_DATA="$(aws ec2 describe-volumes --filters Name=tag-key,Values=Name Name=tag-value,Values=\"${INSTANCE_NAME}-data\" Name=status,Values=available | jq -r '.Volumes[0].VolumeId')"
aws ec2 attach-volume --volume-id "${VOLUME_DOCKER_DATA}" --instance-id "${INSTANCE_ID}" --device /dev/xvdc
sleep 10

if [ -b "/dev/nvme0n1" ]; then
    echo "UUID=$(blkid -s UUID -o value /dev/nvme2n1p1) /mnt/data xfs defaults 0 0" >> /etc/fstab
elif [ -b "/dev/xvda" ]; then
    echo "UUID=$(blkid -s UUID -o value /dev/xvdc1) /mnt/data xfs defaults 0 0" >> /etc/fstab
else
    echo "UUID=$(blkid -s UUID -o value /dev/sdc1) /mnt/data xfs defaults 0 0" >> /etc/fstab
fi
mkdir -p /mnt/data
mount /mnt/data

if [ ! -e /mnt/config/docker ]; then
    service docker start
    docker swarm init
    docker swarm join-token manager
    sleep 30
    service docker stop
    mkdir -p /mnt/config/docker
    cp -a /var/lib/docker /mnt/config/docker
fi

rm -rf /var/lib/docker
ln -s /mnt/config/docker /var/lib/docker
chkconfig --level 345 docker on
service docker start

ECS_ACCOUNT_ID="<AWS ACOUNT ID>"
aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${ECS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com

cd /mnt/config
#docker stack deploy -c docker-compose.yml --with-registry-auth --prune elastic-stack
docker-compose up -d

history -c