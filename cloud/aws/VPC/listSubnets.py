import boto3, json, os

sts = boto3.client("sts")

ACCOUNT_INFOS = [
    {"ID": "<ACCOUNT ID>", "NAME": "<ACCOUNT NAME>"}, 
    {"ID": "<ACCOUNT ID>", "NAME": "<ACCOUNT NAME>"}  
]
ROLE_NAME = "admin"

for ACCOUNT_INFO in ACCOUNT_INFOS:
    ACCOUNT_ID = ACCOUNT_INFO['ID']
    print('CONTA - ' + ACCOUNT_INFO['NAME'])
    
    if ACCOUNT_ID != '<MAIN ACCOUNT ID THAT NOT USE ASSUME ROLE>':
        assumedRole = sts.assume_role(    
            RoleArn="arn:aws:iam::" + ACCOUNT_ID + ":role/" + ROLE_NAME,
            RoleSessionName="AssumeRole" + ACCOUNT_ID + ROLE_NAME
        )
        credentials = assumedRole["Credentials"]

        ec2 = boto3.client(
            'ec2',
            aws_access_key_id=credentials['AccessKeyId'],
            aws_secret_access_key=credentials['SecretAccessKey'],
            aws_session_token=credentials['SessionToken']
        )
    else:
        ec2 = boto3.client('ec2')

    for vpc in ec2.describe_vpcs()['Vpcs']:
        print('VPC - ' + vpc['VpcId'] + ' - ' + vpc['CidrBlockAssociationSet'][0]['CidrBlock'])        
        for subnet in ec2.describe_subnets(Filters=[{'Name': 'vpc-id','Values': [vpc['VpcId']]}])['Subnets']:
            print('  - Subnet - ' + subnet['CidrBlock'] + ' - Public: ' + str(subnet['MapPublicIpOnLaunch']))