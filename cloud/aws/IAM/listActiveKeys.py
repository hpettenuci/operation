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

        iam = boto3.client(
            'iam',
            aws_access_key_id=credentials['AccessKeyId'],
            aws_secret_access_key=credentials['SecretAccessKey'],
            aws_session_token=credentials['SessionToken']
        )
    else:
        iam = boto3.client('iam')

    for user in iam.list_users()['Users']:
        akInfo = iam.list_access_keys(UserName=user['UserName'])
        if (akInfo['AccessKeyMetadata']):
            for key in akInfo['AccessKeyMetadata']:
                if key['Status'] == 'Active':
                    keyLastUsed = iam.get_access_key_last_used(AccessKeyId=key['AccessKeyId'])
                    if 'LastUsedDate' in keyLastUsed['AccessKeyLastUsed']:
                        print("User: " + user['UserName'] + " - " + key['AccessKeyId'] + ' - LAST USE IN '+ str(keyLastUsed['AccessKeyLastUsed']['LastUsedDate']) + ' - ON SERVICE ' + str(keyLastUsed['AccessKeyLastUsed']['ServiceName']))
                    else:
                        print("User: " + user['UserName'] + " - " + key['AccessKeyId'] + ' - ACTIVE BUT NEVER USED')
                else:
                    print("User: " + user['UserName'] + " - " + key['AccessKeyId'] + ' - INACTIVE')