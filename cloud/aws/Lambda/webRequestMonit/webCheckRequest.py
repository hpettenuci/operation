import httplib2,json

def check(hostname, stepInfo):
    fullURL = hostname + stepInfo["url"]    
    
    reqBody=json.dumps(stepInfo["body"])
    print(reqBody)
    connection = httplib2.Http()
    r, content = connection.request(
        uri=fullURL,
        method=stepInfo["method"],        
        body=reqBody,
        headers=stepInfo["header"],
    )
    
    return r,content

def requestTester(event, lambda_context):
    
    inputError = False
    returnCode = 0
    returnMessage = ""
    returnContent = None
    
    # Get Parameters
    hostname = event['hostname']
    stepInfo = event['stepInfo']
    
    if hostname == "":
        inputError = True
        returnCode = -1000
        returnMessage = "Invalid hostname!"
        returnContent = None
        
    if stepInfo == "":
        inputError = True
        returnCode = -1001
        returnMessage = "Invalid request info!"
        returnContent = None
        
    if not inputError:        
        reqReturn, reqContent = check(hostname, stepInfo)
        
        returnCode = reqReturn.status
        returnMessage = "Request returned status code " + str(reqReturn.status)
        reqContent = reqContent.decode("utf-8")

        if reqContent != "":            
            try:
                returnContent = json.loads(reqContent)
            except:
                returnContent = reqContent
                        
    # Return Block
    print("Return Status Code: " + str(returnCode))
    print("Return Message: " + returnMessage)
    return { 
        "status"  : returnCode,
        "message" : returnMessage,
        "content" : returnContent
    }