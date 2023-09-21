# Multi-cloud Asset Inventory Management

Multi-cloud asset inventory management allows you to see an up-to-date view of your resources from other public clouds in Azure. This will enable you to see all cloud resources in a single place. In addition, you can query for all your cloud resources through Azure Resource Graph. WWhen the assets are represented in Azure, we pull all the metadata from the source cloud along with tags in the source cloud. For instance, if you need to query for resources with a certain tag (from Azure or AWS), you can do so with multi-cloud asset inventory.  Asset Management will scan your AWS account at configured periodic interval default to 1 hour. to ensure we have a complete, correct view represented in Azure.

With this private preview feature, you can onboard AWS EC2 instances, S3 buckets and Lambda functions to Azure as multi-cloud asset inventories, new resources created in your AWS account will also be automatically connected to Azure. 

- Please do <code style="color : red">NOT</code> try this feature in production environments.
  
- Please do <code style="color : red">NOT</code> try this feature if you are already using a connector from Microsoft Defender for Cloud (MDC) to onboard your AWS/GCP resources to Azure Arc in production environments.

- Please do <code style="color : red">NOT</code> try this feature if you are already using a connector from [Azure Arc Public Cloud At-scale Onboarding](https://github.com/Azure/azure-arc-publicclouds-preview).

- Arc-enabled EC2 Instance: If your machine is already onboarded to Arc, you <code style="color : red">CANNOT</code> see this in Multi-cloud Asset Inventory at this time.

# Getting started
# Overview
Leverage Multi-cloud asset inventory to see all your cloud resources in a single portal. Once the AWS connection is established, you can see your AWS resources represented as Azure resources. 

Note: these resources are just read-only for inventory purposes. The resources in AWS are not modified.  


# Prerequisites
- Supported AWS account: single account 

- Supported AWS resource types: 
    - EC2
    - S3 Bucket
    - Lambda

- Supported AWS regions:
    - us-east-1
  	- us-east-2
  	- us-west-1
  	- us-west-2  

- Supported Azure regions: 
    - East US

- Use Azure Cloud Shell https://shell.azure.com  or Install az cli using below links
    - For windows https://aka.ms/installazurecliwindows 
    - For Linux https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt

- Login into [Azure Cloud Shell](https://portal.azure.com/#cloudshell/) or a local terminal.

    ```
    az login
    az account set -s <subscription name/ID>
    ```

# Setup instructions

## Set variables
### AWS account ID
This information can be retrieve the top right corner of the AWS management console.
```
awsAccountId="<AWS account ID>"
```
```
# The name of the azure region where we create resource group
azureLocation="eastus"

# The name of the resource group
resourceGroupName="RG-AssetMgmt"

# Create a resource group with the set name and location
az group create -n ${resourceGroupName} -l ${azureLocation}

# The subscription Id in which the resource group is created
subscriptionId=$(az account show --query id -o tsv)

# The name used in creating the public cloud connector object
publicCloudConnectorName="aws_connector_${awsAccountId}"

# The name used in creating the solution configuration object
solutionConfigurationName="aws_solutionconfig_${awsAccountId}"

# AWS services to import
awsServicesToImport="ec2,s3,lambda"
```

## Export variables
```
export subscriptionId
export resourceGroupName
export azureLocation
export publicCloudConnectorName
export solutionConfigurationName
export awsAccountId
export awsServicesToImport
```

## Download the onboarding scripts
```
wget https://balupublicclouds.blob.core.windows.net/assetmanagement/AssetManagementOnboardScript.sh; chmod +x ./AssetManagementOnboardScript.sh
```

## Execute the onboarding scripts
```
sh ./AssetManagementOnboardScript.sh
```

## Configure AWS account
On the AWS side, a CloudFormation template needs to be uploaded to create the required identity provider and role permissions to complete the onboarding process.

- Follow the last line on the terminal and download the AWS CloudFormation template from [https://aka.ms/AwsAssetManagementProd](https://aka.ms/AwsAssetManagementProd) and <code style="color : red">PublicCloudConnectorAzureTenantId</code>.
![CleanShot 2023-09-21 at 12 17 59](https://github.com/Azure/multi-cloud-asset-inventory-preview/assets/35560783/2b36c41a-21d1-45ae-bea0-c04572ee1050)
  

- Move to [AWS management console](https://aws.amazon.com/console) to complete the AWS CloudFormation template upload process, please note that **Azure tenant ID** is required.

- Perform the following operations with an AWS user with xxx permissions. Please refer to [this document](https://docs.aws.amazon.com/streams/latest/dev/setting-up.html) for how to grant  permissions to a user should you have any question.

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



## (Optional) Perform a solution configuration create operation
The solution configuration outlines the purpose of an onboard Arc server solution, designed to operate at a large scale. Create a file with the name "SolutionConfigurationRequest.json". 

If you are <code style ="color : red">NOT</code> seeing AWS resources such as EC2 instances, S3 buckets and Lambda functions being onboarded to Azure as multi-cloud asset inventories, please execute the following command once more to trigger the operation.

```
{
	"properties": {
		"solutionType": "Microsoft.AssetManagement",
		"solutionSettings": {
			"cloudProviderServiceTypes": "s3, lambda, ec2"
		}
	}
}
```

```
az rest --method put --url https://management.azure.com/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName}/providers/Microsoft.HybridConnectivity/publicCloudConnectors/${publicCloudConnectorName}/providers/Microsoft.HybridConnectivity/solutionConfigurations/${solutionConfigurationName}?api-version=2023-04-01-preview --body @SolutionConfigurationRequest.json --verbose

```




#  View resources
Onboarded multi-cloud asset inventories will be shown under the newly create resource group called "aws_{AWS account ID}"; Public cloud connector and solution configuration resources will be shown under the self-created resource group.

## Azure portal
- Wait for 1 minute and head over to the resource group "RG-AssetMgmt", select "Show hidden type" to check for the public cloud connector resource.
![CleanShot 2023-09-20 at 14 10 49](https://github.com/Azure/multi-cloud-asset-inventory-preview/assets/35560783/db8e335b-fba8-46d3-bc6d-925217fda482)


- Head to the resource group "aws_[AWS account ID]" to check for onboarded EC2 instances. The status will show as below.
![CleanShot 2023-09-20 at 14 11 55](https://github.com/Azure/multi-cloud-asset-inventory-preview/assets/35560783/9d791892-96c9-4040-bd08-d40175488900)
![CleanShot 2023-09-20 at 14 12 55](https://github.com/Azure/multi-cloud-asset-inventory-preview/assets/35560783/fbedbea2-f953-4d3b-8ebd-22576eb7b91c)


- Stay the resource group "aws_[AWS account ID]", select "Show hidden type" to view onboarded S3 buckets and Lambda functions.
![CleanShot 2023-09-20 at 14 13 37](https://github.com/Azure/multi-cloud-asset-inventory-preview/assets/35560783/0aef9534-3ede-4ec1-b016-38b7b4747f57)


### Azure Resource Graph
- Azure Resource Graph is an Azure service designed to extend Azure Resource Management by providing efficient and performant resource exploration with the ability to query at scale across a given set of subscriptions so that you can effectively govern your environment. For more information, please check [this link](https://learn.microsoft.com/en-us/azure/governance/resource-graph/overview).
  
- Head to [Azure Resource Graph Explorer](https://ms.portal.azure.com/#view/HubsExtension/ArgQueryBlade).
![CleanShot 2023-09-15 at 09 25 32@2x](https://github.com/Azure/azure-arc-publicclouds-preview/assets/35560783/e86f594a-3d09-459d-bd06-8d2a31a3bf9a)

### Scenario: query all onboarded multi-cloud asset inventories.
```
awsresources 
| where subscriptionId == "<yoursubscriptionid>"
| where ['type'] contains "microsoft.awsconnector/ec2instances" 
```
![CleanShot 2023-09-20 at 14 18 27](https://github.com/Azure/multi-cloud-asset-inventory-preview/assets/35560783/bec15c4c-43a0-449c-8d36-e366c8557d8e)

```
resources 
| where subscriptionId == "<yoursubscriptionid>"
| where ['type'] contains "microsoft.awsconnector/S3" or ['type'] contains "Microsoft.AwsConnector/lambdaFunctionConfigurations"
```
![CleanShot 2023-09-20 at 14 29 59](https://github.com/Azure/multi-cloud-asset-inventory-preview/assets/35560783/c92e3acd-a291-4466-b987-33539b14d2cc)



### Scenario: query for all virtual machines and Arc-enabled servers in Azure and onboarded AWS EC2 instances from AWS as multi-cloud asset inventories.
```
awsresources
| where ['type'] contains "microsoft.awsconnector/ec2instances"
```
```
resources 
| where subscriptionId == "<yoursubscriptionid>"
| where ['type'] contains "microsoft.hybridcompute" or ['type'] contains "microsoft.compute"
```


### Scenario: query for all storage accounts and their creation time
```
resources 
| where subscriptionId =="<yoursubscriptionid>" 
| where ['type'] contains "microsoft.awsconnector/S3" or ['type'] contains "microsoft.storage/storageaccount" 
| extend storageAccountCreationTime=iff(type contains "aws", properties.awsProperties.creationDate, properties.creationTime), cloud=iff(['type'] contains "aws", "aws", "azure") 
| project cloud, subscriptionId, resourceGroup, name, storageAccountCreationTime 
```

### Scenario: query for all resources with certain tag 
```
resources 
| extend awsTags=iff(type contains "microsoft.awsconnector", properties.awsTags, ""), azureTags=tags 
| where awsTags contains "<yourTagValue>" or azureTags contains "<yourTagValue>" 
| project subscriptionId, resourceGroup, name, azureTags, awsTags 
```

### Scenario: query for all resources types in AWS Account 
```
resources 
| where resourceGroup contains "<yourAccountId>" and ['type'] !contains "hybridcompute" 
| extend aws_ResourceName=properties.awsResourceName, aws_AccountId=properties.awsAccountId, publicCloudConnectorId=properties.publicCloudConnectorsResourceId, awsTags=properties.awsTags, awsRegion=properties.awsRegion 
| parse publicCloudConnectorId with * "microsoft.hybridconnectivity/publiccloudconnectors/" publicCloudConnectorName 
| extend awsRegion=iff(awsRegion!="", awsRegion, "global") 
| project subscriptionId, aws_AccountId, type, name, aws_ResourceName, publicCloudConnectorName, awsTags, awsRegion, properties
``` 

## CLI

### Verify the creation of public cloud connector resource
To verify, please ensure that provisioningState= "Succeeded" by running following command.
```
az rest --method get --url https://management.azure.com/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName}/providers/Microsoft.HybridConnectivity/publicCloudConnectors/${publicCloudConnectorName}?api-version=2023-04-01-preview --verbose
```

Alternatively, the public cloud connector resource can be viewed within the resource group "RG-AssetMgmt" with "show hidden resources" selected.

### Verify the creation of solution configuration resource
To verify, please ensure that provisioningState= "Succeeded" by running following command
```
az rest --method get --url https://management.azure.com/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName}/providers/Microsoft.HybridConnectivity/publicCloudConnectors/${publicCloudConnectorName}/providers/Microsoft.HybridConnectivity/solutionConfigurations/${solutionConfigurationName}?api-version=2023-04-01-preview --verbose
```

### Verify all onboarded multi-cloud asset inventories
```
# All
az resource list -g "aws_${awsAccountId}"

# EC2 
az rest --method get --url https://management.azure.com/subscriptions/${subscriptionId}/resourceGroups/aws_${awsAccountId}/providers/Microsoft.AWSConnector/ec2Instances?api-version=2023-04-01-preview --verbose

# S3
az rest --method get --url https://management.azure.com/subscriptions/${subscriptionId}/resourceGroups/aws_${awsAccountId}/providers/Microsoft.AWSConnector/s3buckets?api-version=2023-04-01-preview --verbose

# Lambda
az rest --method get --url https://management.azure.com/subscriptions/${subscriptionId}/resourceGroups/aws_${awsAccountId}/providers/Microsoft.AWSConnector/lambdaFunctionConfigurations?api-version=2023-04-01-preview --verbose

```



# Clean up resources
## AWS operations
### Clean up EC2, S3 and Lambda.
![CleanShot 2023-09-20 at 14 34 47](https://github.com/Azure/multi-cloud-asset-inventory-preview/assets/35560783/d11a352b-829b-416a-afe5-050fb42e51cb)


### Clean up the stack.
![CleanShot 2023-09-20 at 14 35 56](https://github.com/Azure/multi-cloud-asset-inventory-preview/assets/35560783/be7dba58-202c-4345-8435-f0db4d627c92)



## Azure operations
Once AWS EC2, S3 and Lambda resources are deleted, their Azure representation will be automatically cleaned up in the next periodic sync if the solution configuration is not deleted.

### Clean up all the public cloud connector and the solution configuration.
```
az group delete -n ${resourceGroupName}
```

### Clean up all onboarded multi-cloud asset inventories.
```
az group delete -n "aws__${awsAccountId}"
```


## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft 
trademarks or logos is subject to and must follow 
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
