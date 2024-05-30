##  View and query asset inventory
Public cloud connector and solution configuration resources will be shown under the newly created resource group "aws-asset-management-rg"; onboarded multi-cloud asset inventories will be shown under the newly create resource group called "aws_{AWS account ID}".

### Azure portal
- Wait for 1 minute and head over to the resource group "aws-asset-management-rg", select "Show hidden type" to check for the public cloud connector resource.
![CleanShot 2023-10-05 at 16 21 17@2x](https://github.com/Azure/multi-cloud-asset-inventory-preview/assets/35560783/d58ca947-c4af-436e-b5e0-628b1be5ed56)


- Head to the resource group "aws_[AWS account ID]" to check for onboarded EC2 instances. The status will show as below.
![CleanShot 2023-10-05 at 16 22 57@2x](https://github.com/Azure/multi-cloud-asset-inventory-preview/assets/35560783/73b505f5-a8ae-4c3a-a710-20c5a0732d64)
![CleanShot 2023-10-05 at 16 24 04@2x](https://github.com/Azure/multi-cloud-asset-inventory-preview/assets/35560783/84395229-0a33-49d2-bf51-ba6baaf51201)


- Stay the resource group "aws_[AWS account ID]", select "Show hidden type" to view onboarded S3 buckets and Lambda functions.
![CleanShot 2023-10-05 at 16 26 43@2x](https://github.com/Azure/multi-cloud-asset-inventory-preview/assets/35560783/34b3b86d-fa95-42cd-aa04-f7073777d2be)


#### Azure Resource Graph
- Azure Resource Graph is an Azure service designed to extend Azure Resource Management by providing efficient and performant resource exploration with the ability to query at scale across a given set of subscriptions so that you can effectively govern your environment. For more information, please check [this link](https://learn.microsoft.com/en-us/azure/governance/resource-graph/overview).
  
- Head to [Azure Resource Graph Explorer](https://ms.portal.azure.com/#view/HubsExtension/ArgQueryBlade).
![CleanShot 2023-10-05 at 16 29 46@2x](https://github.com/Azure/multi-cloud-asset-inventory-preview/assets/35560783/1e8e1f31-3cb4-4525-8cfd-21d263a5e71a)



- Scenario: query all onboarded multi-cloud asset inventories.
```
resources
| where subscriptionId == "<subscription ID>"
| where id contains "microsoft.awsconnector" 
| union (awsresources | where type == "microsoft.awsconnector/ec2instances" and subscriptionId =="<subscription ID>")
| extend awsTags= properties.awsTags, azureTags = ['tags']
| project subscriptionId, resourceGroup, type, id, awsTags, azureTags, properties 
```


- Scenario: query for all resources under a specific connector
```
resources
| extend connectorId = tolower(tostring(properties.publicCloudConnectorsResourceId)), resourcesId=tolower(id)
| join kind=leftouter (
    awsresources
    | extend pccId = tolower(tostring(properties.publicCloudConnectorsResourceId)), awsresourcesId=tolower(id)
    | extend parentId = substring(awsresourcesId, 0, strlen(awsresourcesId) - strlen("/providers/microsoft.awsconnector/ec2instances/default"))
) on $left.resourcesId == $right.parentId
| where connectorId =~ "yourConnectorId" or pccId =~ "yourConnectorId"
| extend resourceType = tostring(split(iif (type =~ "microsoft.hybridcompute/machines", type1, type), "/")[1])
```

- Scenario: query for all virtual machines in Azure and AWS along with their instance size
```
resources 
| where (['type'] == "microsoft.compute/virtualmachines") 
| union (awsresources | where type == "microsoft.awsconnector/ec2instances")
| extend cloud=iff(type contains "ec2", "AWS", "Azure")
| extend awsTags=iff(type contains "microsoft.awsconnector", properties.awsTags, ""), azureTags=tags
| extend size=iff(type contains "microsoft.compute", properties.hardwareProfile.vmSize, properties.awsProperties.instanceType.value)
| project subscriptionId, cloud, resourceGroup, id, size, azureTags, awsTags, properties
```

- Scenario: query for all functions across Azure and AWS
```
resources
| where (type == 'microsoft.web/sites' and ['kind'] contains 'functionapp') or type == "microsoft.awsconnector/lambdafunctionconfigurations"
| extend cloud=iff(type contains "awsconnector", "AWS", "Azure")
| extend functionName=iff(cloud=="Azure", properties.name,properties.awsProperties.functionName), state=iff(cloud=="Azure", properties.state, properties.awsProperties.state), lastModifiedTime=iff(cloud=="Azure", properties.lastModifiedTimeUtc,properties.awsProperties.lastModified), location=iff(cloud=="Azure", location,properties.awsRegion),  tags=iff(cloud=="Azure", tags, properties.awsTags)
| project cloud, functionName, lastModifiedTime, location, tags
```

- Scenario: query for all resources with certain tag 
```
resources 
| extend awsTags=iff(type contains "microsoft.awsconnector", properties.awsTags, ""), azureTags=tags 
| where awsTags contains "<yourTagValue>" or azureTags contains "<yourTagValue>" 
| project subscriptionId, resourceGroup, name, azureTags, awsTags 
```

### CLI
### View all onboarded multi-cloud asset inventories
```
az resource list -g aws_${awsAccountId} -o table
```
