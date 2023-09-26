# Multi-cloud Asset Inventory Management

- [Overview](https://github.com/Azure/multi-cloud-asset-inventory-preview/tree/main#overview)
- [Getting started](https://github.com/Azure/multi-cloud-asset-inventory-preview/tree/main#getting-started)
- [View resources](https://github.com/Azure/multi-cloud-asset-inventory-preview/tree/main#view-resources)
- [Troubleshooting](https://github.com/Azure/multi-cloud-asset-inventory-preview/tree/main#troubleshooting)
- [Clean up resources](https://github.com/Azure/multi-cloud-asset-inventory-preview/tree/main#clean-up-resources)
- [Support](https://github.com/Azure/multi-cloud-asset-inventory-preview/tree/main#support)
- [Code of conduct](https://github.com/Azure/multi-cloud-asset-inventory-preview/tree/main#code-of-conduct)

## Overview
Multi-cloud asset inventory management allows you to see an up-to-date view of your resources from other public clouds in Azure. This will enable you to see all cloud resources in a single place. In addition, you can query for all your cloud resources through Azure Resource Graph. When the assets are represented in Azure, we pull all the metadata from the source cloud along with tags in the source cloud. For instance, if you need to query all of your Azure and AWS resources with a certain tag, you can do so with multi-cloud asset inventory.  Asset Management will scan your AWS account at configured periodic interval default to 1 hour. to ensure we have a complete, correct view represented in Azure. Onboarded multi-cloud asset inventories are just read-only resources.

With this private preview feature, you can import AWS EC2 instances, S3 buckets and Lambda functions to Azure as multi-cloud asset inventories. Periodically (default to 1 hour) we scan for new resources created in your AWS account and import them into Azure.

- Please do <code style="color : red">NOT</code> try this feature in production environments.
  
- Please do <code style="color : red">NOT</code> try this feature if you are already using a connector from Microsoft Defender for Cloud (MDC) to onboard your AWS/GCP resources to Azure Arc in production environments.

- Please do <code style="color : red">NOT</code> try this feature if you are already using a connector from [Azure Arc Public Cloud At-scale Onboarding](https://github.com/Azure/azure-arc-publicclouds-preview).

- Arc-enabled EC2 Instance: If your AWS EC2 instance is already onboarded to Arc as an Arc-enabled server, you will see a duplicate `Microsoft.HybridCompute` resource (with a different resource ID) in multi-cloud inventory.

## Getting started

### Prerequisites
- Supported AWS account type: single account
  
  - Organization account will be supported in the future release.

- Supported AWS resource types: 
    - EC2
    - S3 Bucket
    - Lambda

- Supported AWS regions: only AWS resources in these AWS regions will be onboarded to Azure.
    - us-east-1
    - us-east-2
    - us-west-1
    - us-west-2  

- Supported Azure regions: 
    - East US

- Login into [Azure Cloud Shell](https://portal.azure.com/#cloudshell/) and use `bash`.

    ```
    az login
    az account set -s <subscription name/ID>
    ```

### Setup instructions
It is strongly encouraged to run AWS operations prior to Azure operations.

#### AWS operations
##### Configure AWS account
On the AWS side, a CloudFormation template needs to be uploaded to create the required identity provider and role permissions to complete the onboarding process.

- Download the <code style="color : red">AWS CloudFormation template</code> from [https://aka.ms/AwsAssetManagementProd](https://aka.ms/AwsAssetManagementProd)
- <code style="color : red">PublicCloudConnectorAzureTenantId</code> can be retrieved with the following command in Azure Cloud Shell.
```
az account show --query tenantId -o tsv
```
![CleanShot 2023-09-26 at 16 51 40@2x](https://github.com/Azure/multi-cloud-asset-inventory-preview/assets/35560783/8ad77cea-31ac-4bc6-8327-428d2b0186be)
  

- Move to [AWS management console](https://aws.amazon.com/console) to complete the AWS CloudFormation template upload process.

- Perform the following operations with an AWS user with the following permissions. Please refer to [this document](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_change-permissions.html#users_change_permissions-add-console) for how to grant  permissions to a user should you have any question.
  - AmazonS3FullAccess
  - AWSCloudFormationFullAccess
  - IAMFullAccess
![CleanShot 2023-09-21 at 14 14 04](https://github.com/Azure/multi-cloud-asset-inventory-preview/assets/35560783/e8b5a36a-3815-4501-abc2-c497a3fa671e)
   

- Deploy the CloudFormation template by going to AWS management console --> CloudFormation --> Stacks --> Create Stacks.
![CleanShot 2023-09-20 at 14 06 09](https://github.com/Azure/multi-cloud-asset-inventory-preview/assets/35560783/7c4406ee-cc01-448e-97a8-6d89cc3ee358)


- Select "Template is ready". --> "Upload a template file" --> "Choose file" --> Upload the template file, AwsAssetManagementProd.template, downloaded from the previous step.
![CleanShot 2023-09-15 at 08 06 59@2x](https://github.com/Azure/azure-arc-publicclouds-preview/assets/35560783/5f6ebbaf-9d02-418a-b74e-31967ded6a98)

- Provide a stack name " Stack-AssetMgmtSingleAcct" and input the Azure AD tenant ID retrieved from the previous step.
![CleanShot 2023-09-15 at 08 10 55@2x](https://github.com/Azure/azure-arc-publicclouds-preview/assets/35560783/886d6894-48e2-46c5-9a1a-33b9bd7c601d)


- Leave everything as default in the next page and click "Next"
![CleanShot 2023-09-14 at 16 29 21@2x](https://github.com/Azure/azure-arc-publicclouds-preview/assets/35560783/8d2431b3-223a-4c31-959f-275d8f80b127)

- Confirm all information is correct and check "I acknowledge ..." to submit the stack creation request.
![CleanShot 2023-09-14 at 16 29 51@2x](https://github.com/Azure/azure-arc-publicclouds-preview/assets/35560783/6fad050c-1848-4432-8d98-5de81d22d35f)


#### Azure operations
- Perform the following operations with an Azure user with the <code style="color : red">Contributor</code> role at the subscription scope. Please refer to [this document](https://learn.microsoft.com/en-us/azure/role-based-access-control/role-assignments-portal?tabs=delegate-condition) for how to assign roles in Azure portal.

- In cloud shell, let's start by creating a set of environment variables that will be used in the onboarding script. Note you will need to fill in the parameters in.

##### Set variables
- Retrieve AWS account ID from the top right corner of the [AWS management console](https://aws.amazon.com/console/).
- Configure the variables below in [Azure Cloud Shell](https://shell.azure.com).
```
awsAccountId="<AWS account ID>"
```
```
# The subscription Id in which the resource group is created
subscriptionId=$(az account show --query id -o tsv)

# AWS services to import. It supports a subset of the AWS services below. For example, you could pick just "ec2,s3".
awsServicesToImport="ec2,s3,lambda"

# Import AWS resources periodically. Allowed values are true (Default), false.
periodicSync=true

# Frequency in hours, at which Azure imports the AWS resources. Allowed values are 1 (Default), 2, 4, 6, 12, 24.
periodicSyncTime=1
```

##### Export variables
```
export awsAccountId
export subscriptionId
export awsServicesToImport
export periodicSyncTime
export periodicSync
```

##### Execute the onboarding scripts
```
sh https://raw.githubusercontent.com/Azure/multi-cloud-asset-inventory-preview/main/src/AssetManagementOnboardScript.sh
```



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

## Troubleshooting
This step can be used when you are not seeing AWS resources that should be onboarded showing in Azure.
```
az rest --method get --url https://management.azure.com/subscriptions/${subscriptionId}/resourceGroups/aws-asset-management-rg/providers/Microsoft.HybridConnectivity/publicCloudConnectors/aws-connector-${awsAccountId}/providers/Microsoft.HybridConnectivity/solutionConfigurations/aws-asset-management?api-version=2023-04-01-preview --verbose
```

## Clean up resources

### Azure operations
Clean up all the public cloud connector, the solution configuration and all onboarded multi-cloud asset inventories.
```
sh https://raw.githubusercontent.com/Azure/multi-cloud-asset-inventory-preview/main/src/AssetManagementOffboardScript.sh
```

### AWS operations
Clean up the stack.
![CleanShot 2023-09-20 at 14 35 56](https://github.com/Azure/multi-cloud-asset-inventory-preview/assets/35560783/be7dba58-202c-4345-8435-f0db4d627c92)


## Support
Please see our [support policy](https://github.com/Azure/multi-cloud-asset-inventory-preview/blob/main/SUPPORT.md).

## Code of conduct
This project has adopted the Microsoft Open Source Code of Conduct. For more information, see the [Code of Conduct FAQ](https://github.com/Azure/multi-cloud-asset-inventory-preview/blob/main/CODE_OF_CONDUCT.md) or contact opencode@microsoft.com with any additional questions or comments.
