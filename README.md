# Multi-cloud Asset Inventory Management

- [Overview](https://github.com/Azure/multi-cloud-asset-inventory-preview/tree/main#overview)
- [Getting started](https://github.com/Azure/multi-cloud-asset-inventory-preview/tree/main#getting-started)
- [View and query asset inventory](https://github.com/Azure/multi-cloud-asset-inventory-preview/tree/main#view-and-query-asset-inventory)
- [Troubleshooting](https://github.com/Azure/multi-cloud-asset-inventory-preview/tree/main#troubleshooting)
- [Offboard asset inventory](https://github.com/Azure/multi-cloud-asset-inventory-preview/tree/main#offboard-asset-inventory)
- [Support](https://github.com/Azure/multi-cloud-asset-inventory-preview/tree/main#support)
- [Code of conduct](https://github.com/Azure/multi-cloud-asset-inventory-preview/tree/main#code-of-conduct)

## Overview
Multi-cloud asset inventory management allows you to see an up-to-date view of your resources from other public clouds in Azure. This will enable you to see all cloud resources in a single place. In addition, you can query for all your cloud resources through Azure Resource Graph. When the assets are represented in Azure, we pull all the metadata from the source cloud along with tags in the source cloud. For instance, if you need to query all of your Azure and AWS resources with a certain tag, you can do so with multi-cloud asset inventory.  Asset Management will scan your AWS account at configured periodic interval default to 1 hour. to ensure we have a complete, correct view represented in Azure. Onboarded multi-cloud asset inventories are just read-only resources.

With this private preview feature, you can import AWS EC2 instances, S3 buckets and Lambda functions to Azure as multi-cloud asset inventories. Periodically (default to 1 hour) we scan for new resources created in your AWS account and import them into Azure.

- Please do `NOT` try this feature in production environments.
  
- Please do `NOT` try this feature if you are already using a connector from Microsoft Defender for Cloud (MDC) to onboard your AWS/GCP resources to Azure Arc in production environments.

- Please do `NOT` try this feature if you are already using a connector from [Azure Arc Public Cloud At-scale Onboarding](https://github.com/Azure/azure-arc-publicclouds-preview).

- Arc-enabled EC2 Instance: If your AWS EC2 instance is already onboarded to Arc as an Arc-enabled server, you will see a duplicate `Microsoft.HybridCompute` resource (with a different resource ID) in multi-cloud inventory.

## Getting started
Click [here](https://pcaso.blob.core.windows.net/pp1/multicloud-asset-inventory-onboarding.mp4) to watch the tutorial video!

### Prerequisites

#### AWS
- Ensure to perform AWS operations as an AWS user with the following permissions. Please refer to [this document](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_change-permissions.html#users_change_permissions-add-console) for how to grant  permissions to a user should you have any question.
  - AmazonS3FullAccess
  - AWSCloudFormationFullAccess
  - IAMFullAccess
![CleanShot 2023-09-28 at 13 50 03@2x](https://github.com/Azure/multi-cloud-asset-inventory-preview/assets/35560783/d0522c44-9591-4a4e-bfe0-b77e14ed56d7)


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

#### Azure
- Ensure to perform Azure operations as an Azure user with the `Contributor` role at the subscription scope. Please refer to [this document](https://learn.microsoft.com/en-us/azure/role-based-access-control/role-assignments-portal?tabs=delegate-condition) for how to assign roles in Azure portal.
![CleanShot 2023-09-28 at 14 04 31](https://github.com/Azure/multi-cloud-asset-inventory-preview/assets/35560783/e5e6537c-d3f1-4528-9f7e-bb78c36f3ab4)



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

- Download the `AWS CloudFormation template` from [https://aka.ms/AwsAssetManagementProd](https://aka.ms/AwsAssetManagementProd)
- `PublicCloudConnectorAzureTenantId` can be retrieved with the following command in Azure Cloud Shell.
  ```
  az account show --query tenantId -o tsv
  ```
  ![CleanShot 2023-09-28 at 13 55 59](https://github.com/Azure/multi-cloud-asset-inventory-preview/assets/35560783/554b8f16-d3d1-4bc2-af71-2a8d987d6ba1)

- Move to [AWS management console](https://aws.amazon.com/console) to complete the AWS CloudFormation template upload process.

- Deploy the CloudFormation template by going to AWS management console --> CloudFormation --> Stacks --> Create Stacks.
![CleanShot 2023-09-28 at 14 02 13@2x](https://github.com/Azure/multi-cloud-asset-inventory-preview/assets/35560783/c905ed32-0fa5-47b7-a7f6-2ed4062182fc)

- Select "Template is ready". --> "Upload a template file" --> "Choose file" --> Upload the template file, AwsAssetManagementProd.template, downloaded from the previous step.
![CleanShot 2023-09-15 at 08 06 59@2x](https://github.com/Azure/azure-arc-publicclouds-preview/assets/35560783/5f6ebbaf-9d02-418a-b74e-31967ded6a98)

- Provide a stack name " Stack-AssetMgmtSingleAcct" and input the Azure AD tenant ID retrieved from the first step.
![CleanShot 2023-09-15 at 08 10 55@2x](https://github.com/Azure/azure-arc-publicclouds-preview/assets/35560783/886d6894-48e2-46c5-9a1a-33b9bd7c601d)


- Leave everything as default in the next page and click "Next"
![CleanShot 2023-09-14 at 16 29 21@2x](https://github.com/Azure/azure-arc-publicclouds-preview/assets/35560783/8d2431b3-223a-4c31-959f-275d8f80b127)

- Confirm all information is correct and check "I acknowledge ..." to submit the stack creation request.
![CleanShot 2023-09-14 at 16 29 51@2x](https://github.com/Azure/azure-arc-publicclouds-preview/assets/35560783/6fad050c-1848-4432-8d98-5de81d22d35f)


#### Azure operations
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

#### Download the onboarding scripts
```
wget https://github.com/Azure/multi-cloud-asset-inventory-preview/blob/main/src/AssetManagementOnboardScript.sh; chmod +x ./AssetManagementOnboardScript.sh
```

##### Execute the onboarding scripts
```
sh ./AssetManagementOnboardScript.sh
```

## View and query asset inventory
Please see [view and query asset inventory](https://github.com/Azure/multi-cloud-asset-inventory-preview/blob/main/view-and-query-asset-inventory.md).

## Troubleshooting
Please see [troubleshooting](https://github.com/Azure/multi-cloud-asset-inventory-preview/blob/main/troubleshooting.md).

## Offboard asset inventory
Please see [offboard asset inventory](https://github.com/Azure/multi-cloud-asset-inventory-preview/blob/main/offboard-asset-inventory.md).

## Support
Please see our [support policy](https://github.com/Azure/multi-cloud-asset-inventory-preview/blob/main/SUPPORT.md).

## Code of conduct
This project has adopted the Microsoft Open Source Code of Conduct. For more information, see the [Code of Conduct FAQ](https://github.com/Azure/multi-cloud-asset-inventory-preview/blob/main/CODE_OF_CONDUCT.md) or contact opencode@microsoft.com with any additional questions or comments.
