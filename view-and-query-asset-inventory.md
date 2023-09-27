##  View resources
Public cloud connector and solution configuration resources will be shown under the newly created resource group "aws-asset-management-rg"; onboarded multi-cloud asset inventories will be shown under the newly create resource group called "aws_{AWS account ID}".

### Azure portal
- Wait for 1 minute and head over to the resource group "aws-asset-management-rg", select "Show hidden type" to check for the public cloud connector resource.
![CleanShot 2023-09-25 at 16 14 33](https://github.com/Azure/multi-cloud-asset-inventory-preview/assets/35560783/6c41c101-4db1-4814-ae49-b10978ea6f50)

- Head to the resource group "aws_[AWS account ID]" to check for onboarded EC2 instances. The status will show as below.
![CleanShot 2023-09-20 at 14 11 55](https://github.com/Azure/multi-cloud-asset-inventory-preview/assets/35560783/9d791892-96c9-4040-bd08-d40175488900)
![CleanShot 2023-09-20 at 14 12 55](https://github.com/Azure/multi-cloud-asset-inventory-preview/assets/35560783/fbedbea2-f953-4d3b-8ebd-22576eb7b91c)


- Stay the resource group "aws_[AWS account ID]", select "Show hidden type" to view onboarded S3 buckets and Lambda functions.
![CleanShot 2023-09-25 at 16 16 49](https://github.com/Azure/multi-cloud-asset-inventory-preview/assets/35560783/da0b0ae4-7d1c-4e04-ab70-02ec8d5a85f9)

#### Azure Resource Graph
- Azure Resource Graph is an Azure service designed to extend Azure Resource Management by providing efficient and performant resource exploration with the ability to query at scale across a given set of subscriptions so that you can effectively govern your environment. For more information, please check [this link](https://learn.microsoft.com/en-us/azure/governance/resource-graph/overview).
  
- Head to [Azure Resource Graph Explorer](https://ms.portal.azure.com/#view/HubsExtension/ArgQueryBlade).
![CleanShot 2023-09-25 at 16 13 33](https://github.com/Azure/multi-cloud-asset-inventory-preview/assets/35560783/19329844-a0b5-4f03-ae4a-9acc13be8a34)


##### Scenario: query all onboarded multi-cloud asset inventories.
```
resources
| where subscriptionId == "<subscription ID>"
| where resourceGroup == "aws_<AWS account ID>"
| where id contains "microsoft.awsconnector"
```


##### Scenario: query for all virtual machines and Arc-enabled servers in Azure and onboarded AWS EC2 instances from AWS as multi-cloud asset inventories.
```
awsresources
| where ['type'] contains "microsoft.awsconnector/ec2instances"
```
```
resources 
| where subscriptionId == "<yoursubscriptionid>"
| where ['type'] contains "microsoft.hybridcompute" or ['type'] contains "microsoft.compute"
```


##### Scenario: query for all storage accounts and their creation time
```
resources 
| where subscriptionId =="<yoursubscriptionid>" 
| where ['type'] contains "microsoft.awsconnector/S3" or ['type'] contains "microsoft.storage/storageaccount" 
| extend storageAccountCreationTime=iff(type contains "aws", properties.awsProperties.creationDate, properties.creationTime), cloud=iff(['type'] contains "aws", "aws", "azure") 
| project cloud, subscriptionId, resourceGroup, name, storageAccountCreationTime 
```

##### Scenario: query for all resources with certain tag 
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
