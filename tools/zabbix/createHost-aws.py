import json, os, socket, platform, requests
import boto3, consul
from pyzabbix import ZabbixAPI, ZabbixAPIException

def getIPAddress(connHost):
    connSocket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    connSocket.connect((connHost,80))
    return connSocket.getsockname()[0]

def connectConsul(consulInfo):
    return consul.Consul(host=consulInfo["HOST"],port=consulInfo["PORT"],scheme=consulInfo["SCHEME"])

def getConsulKVValue(consulClient,kvPath):
    index,kv = consulClient.kv.get(kvPath)
    return (kv['Value']).decode('utf-8')

def getTagList(instanceId):
    EC2 = boto3.resource('ec2')
    tags = EC2.Instance(instanceId).tags
    tagList = {}

    for tag in tags:
        tagList[tag['Key']] = tag['Value']

    return tagList

def connectZabbix(zabbixInfo):
    zAPI = ZabbixAPI(server=zabbixInfo["SERVER"],)
    zAPI.login(user=zabbixInfo["USER"],password=zabbixInfo["PASS"])
    return zAPI

def getHost(zabbixAPI,hostName):
    return zabbixAPI.host.get(output="extend",filter={"host":[hostName]})

def createHost(zabbixAPI,hostInfo,hostGroups,hostTemplates):
    try:
        createhost = zabbixAPI.host.create(
            host=hostInfo["NAME"],
            interfaces=[{"type": 1, "main": 1, "useip": 1, "ip": hostInfo["IP"], "dns": "", "port": "10050"}],
            groups=hostGroups,
            templates=hostTemplates
        )
    except ZabbixAPIException as fail:
        print("Exception has been thrown. " + str(fail))

def updateHost(zabbixAPI,hostInfo,serverInfo):
    try:               
        interfaceId = zabbixAPI.hostinterface.get(filter={'hostid': serverInfo['hostid']}, output="interfaceid")
        
        zabbixAPI.hostinterface.update(
            interfaceid=interfaceId[0]["interfaceid"],
            port="10050",
            ip=hostInfo["IP"]
        )      
    except ZabbixAPIException as fail:
        print("Exception has been thrown. " + str(fail))

# CONSTAINTS BLOCK
INSTANCE_ID = requests.get('http://169.254.169.254/latest/meta-data/instance-id').text
SERVER_INFO = {
    "NAME"      : socket.gethostname(),
    "IP"        : "127.0.0.1",
    "OS_TYPE"   : platform.system()
}
ZABBIX_INFO = {
    "SERVER": "http://<zabbix server>/zabbix/",
    "USER"  : "zabbix user",
    "PASS"  : "zabbix pass"
}
CONSUL_INFO = {
    "HOST"  : "<consul host>",
    "PORT"  : 8500,
    "SCHEME": "http"
}
DEFAULT_ROOT_PATH       = "zabbix"
DEFAULT_PATH_GROUPS     = DEFAULT_ROOT_PATH + "/default/zabbixGroups"
DEFAULT_PATH_TEMPLATES  = DEFAULT_ROOT_PATH + "/default/zabbixTemplates"

if (__name__ == '__main__'):
    zApi            = connectZabbix(ZABBIX_INFO)
    consulClient    = connectConsul(CONSUL_INFO)
    instanceId      = requests.get('http://169.254.169.254/latest/meta-data/instance-id').text
    instanceTags    = getTagList(instanceId)

    # Get tag Name
    SERVER_INFO['NAME'] = instanceTags['Name']
    serverInfo = getHost(zApi,SERVER_INFO['NAME'])

    # Get IP Address
    SERVER_INFO['IP'] = getIPAddress(CONSUL_INFO['HOST'])
    
    if (len(serverInfo) == 0):
        environment = instanceTags['ambiente']
        customer    = instanceTags['cliente']
        product     = instanceTags['produto']

        instanceGroups = getConsulKVValue(consulClient,DEFAULT_PATH_GROUPS)
        instanceGroups = instanceGroups + "," + getConsulKVValue(consulClient,DEFAULT_ROOT_PATH + "/" + product + "/default/" + environment + "/zabbixGroups")
        instanceGroups = instanceGroups + "," + getConsulKVValue(consulClient,DEFAULT_ROOT_PATH + "/" + product + "/" + customer + "/" + environment + "/zabbixGroups")
        objInstanceGroup = []
        for group in instanceGroups.split(','):
            if (group != ""):
                objInstanceGroup.append({"groupid": group})


        instanceTemplate = getConsulKVValue(consulClient,DEFAULT_PATH_TEMPLATES)
        instanceTemplate = instanceTemplate + "," + getConsulKVValue(consulClient,DEFAULT_ROOT_PATH + "/" + product + "/default/" + environment + "/zabbixTemplates")
        instanceTemplate = instanceTemplate + "," + getConsulKVValue(consulClient,DEFAULT_ROOT_PATH + "/" + product + "/" + customer + "/" + environment + "/zabbixTemplates")
        objInstanceTemplate = []
        for temp in instanceTemplate.split(','):
            if (temp != ""):
                objInstanceTemplate.append({"templateid": temp})

        createHost(
            zApi,
            SERVER_INFO,
            objInstanceGroup,
            objInstanceTemplate 
        )

        print(SERVER_INFO['NAME'] + " created...")
    else:
        updateHost(zApi,SERVER_INFO,serverInfo[0])

        print(SERVER_INFO['NAME'] + " updated...")
