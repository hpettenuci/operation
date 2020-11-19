import boto3, requests, sys
from requests_aws4auth import AWS4Auth

def listIndices(host, auth):
    print("Listing Indices from AWS ES ...")
    req = requests.get(host + '/_cat/indices?v', auth=auth)
    print("HTTP Response Code: " + str(req.status_code) + '\n' + req.text)

def registerSnapshot(host, auth, s3_region_name, s3_bucket_name, role_arn, repo_name):
    headers = {"Content-Type": "application/json"}
    payload = {
            "type": "s3",
            "settings": {
                    "bucket": s3_bucket_name,
                    "role_arn": role_arn
            }
    }

    print("Registering Snapshot with AWS ES ...")
    url = host + '/_snapshot/' + repo_name
    req = requests.put(url, auth=auth, json=payload, headers=headers)
    print("HTTP Response Code: " + str(req.status_code) + '\n' + req.text)

def executeSnapshot(host, auth, repo_name, snapshot_name):
    print("Starting Snapshot with AWS ES ...")
    url = host + '/_snapshot/' + repo_name + '/' + snapshot_name
    req = requests.put(url, auth=auth)
    print("HTTP Response Code: " + str(req.status_code) + '\n' + req.text)

def getSnapshotStatus(host, auth, repo_name, snapshot_name):
    print("Getting Status of Snapshot with AWS ES ...")
    url = host + '/_snapshot/' + repo_name + '/' + snapshot_name + '?pretty'
    req = requests.get(url, auth=auth)
    print("HTTP Response Code: " + str(req.status_code) + '\n' + req.text)

def restoreSnapshot(host, auth, repo_name, snapshot_name):
    print("Starting Restore on ES Cluster...")
    url = host + '/_snapshot/' + repo_name + '/' + snapshot_name + '/_restore'
    req = requests.post(url, auth=auth)
    print("HTTP Response Code: " + str(req.status_code) + '\n' + req.text)


if __name__ == '__main__':
    ES_HOST   = 'http://localhost:9200'
    ES_REGION = 'sa-east-1'

    REPO_NAME = 'backup'
    SNAP_NAME = 'migrate'

    S3_REGION = 'sa-east-1'
    S3_BUCKET = 'migrate-elastic-snapshot'
    ROLE_ARN = ''

    # Get current machine credentials
    creds    = boto3.Session().get_credentials()
    req_auth = AWS4Auth(creds.access_key, creds.secret_key, ES_REGION, 'es', session_token=creds.token)

    optionList = [
        "STATUS",   # Show current snapshot operation
        "INDEX",    # List all index on Elasticsearch
        "REGISTER", # Register a S3 repository to snapshots
        "RESTORE",  # Start a restore from repository
        "SNAPSHOT"  # Start a snapshot process
    ]


    if (len(sys.argv) >= 2):
        option = (str(sys.argv[1])).upper()

        if (option == optionList[0]):
            getSnapshotStatus(ES_HOST, req_auth, REPO_NAME, SNAP_NAME)
        elif (option == optionList[1]):
            listIndices(ES_HOST, req_auth)
        elif (option == optionList[2]):
            registerSnapshot(ES_HOST, req_auth, S3_REGION, S3_BUCKET, ROLE_ARN, REPO_NAME)
        elif(option == optionList[3]):
            restoreSnapshot(ES_HOST, req_auth, REPO_NAME, SNAP_NAME)
        elif(option == optionList[4]):
            executeSnapshot(ES_HOST, req_auth, REPO_NAME, SNAP_NAME)
    else:
        print("Please type one operation...")
        print(optionList)
