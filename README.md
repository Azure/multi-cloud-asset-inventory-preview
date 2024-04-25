# Multi-cloud Connector

- [Overview](https://github.com/Azure/multi-cloud-asset-inventory-preview/tree/main#overview)
- [Getting started with Portal](src/multi-cloud-portal-create.md)
- [Multi-cloud Inventory](src/Inventory-Details.md)
- [Multi-cloud Arc Onboarding](src/Arc-onboarding-details.md)
- [View and query asset inventory](https://github.com/Azure/multi-cloud-asset-inventory-preview/tree/main#view-and-query-asset-inventory)

## Overview
The Microsoft Multi-cloud Connector allows customers to connect their non-Azure public cloud resources to Azure, providing customers with a centralized source for management and governance. Today, the Connector supports AWS environments but we plan to expand to other clouds in the future. The Multi-cloud Connector supports Multi-cloud solutions:
* Multi-cloud Inventory allows you to see an up-to-date view of your resources from other public clouds in Azure, providing you with a single place to see all of your cloud resources. In addition, you can query for all your cloud resources through Azure Resource Graph. When the assets are represented in Azure, metadata from the source cloud is also included. For instance, if you need to query all of your Azure and AWS resources with a certain tag, you can do so with multi-cloud asset inventory. The Inventory solution will scan your source cloud on a periodic basis to ensure a complete, correct view is represented in Azure. You can also apply Azure tags or Azure policies on these resources.
* Arc Onboarding auto-discovers EC2 instances running in your AWS environment and installs the Arc agent on the VMs. This simplified experience will enable customers to onboard to Azure management services such as Azure Monitor, providing a centralized way for customers to manage their Azure and AWS VMs.

## Prerequisite
You need to have the following permissions in AWS to create the connector and solutions.  Please refer to [this document](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_change-permissions.html#users_change_permissions-add-console) for how to grant  permissions to a user should you have any question.
For the Connector & Inventory solution: 
  - AmazonS3FullAccess
  - AWSCloudFormationFullAccess
  - IAMFullAccess
![CleanShot 2023-09-28 at 13 50 03@2x](https://github.com/Azure/multi-cloud-asset-inventory-preview/assets/35560783/d0522c44-9591-4a4e-bfe0-b77e14ed56d7)

For the Arc Onboarding solution, you also need the following: 
  - AmazonEC2FullAccess permissions
  - EC2 instances need to have the SSM agent installed. The IAM role of `ArcForServerSSMInstanceProfile` will be generated during the onboarding process.

In Azure, to create the Connector and Solutions, you need to have write access to the Resource Group you are placing those resources in. If this is the first time you are using the service, you will also need to register the following resource providers which requires Contributor access on the subscription:
- Microsoft.HybridConnectivity
- Microsoft.AwsConnector

## Supported Regions
In Azure, you will need to create the connector and solution configurations in one of the supported Azure regions below: 
- West US 2, South Central US, UK South, Southeast Asia, West Europe, Esat US, Australia East, East US 2, North Europe, West US 3, Sweden Central, Finland Central

In AWS, we will scan for resources in the following regions: 
- us-east-1, us-east-2, us-west-1, us-west-2, ca-central-1, ap-southeast-1, ap-southeast-2, ap-northeast-1, ap-northeast-3, eu-west-1, eu-west-2, eu-central-1, eu-north-1, sa-east-1

## Unsupported scenarios
For EC2 instances that already have the Arc agent, please do not use the inventory solution. This will create a duplicate record of the EC2 instance in Azure. We are planning on supporting existing EC2 VMs with the Arc agent installed and just reusing the existing resource for inventory. 

## Next Steps:
- [Get Started with Azure Portal](src/multi-cloud-portal-create.md)
- [Learn more about the Connector and Auth](src/Connector-details.md)
- [Learn more about Inventory Solution](src/Inventory-Details.md)
- [Learn more about Arc onboarding solution](src/Arc-onboarding-details.md)
- [view and query asset inventory](https://github.com/Azure/multi-cloud-asset-inventory-preview/blob/main/view-and-query-asset-inventory.md).

## Support
Please see our [support policy](https://github.com/Azure/multi-cloud-asset-inventory-preview/blob/main/SUPPORT.md).

## Code of conduct
This project has adopted the Microsoft Open Source Code of Conduct. For more information, see the [Code of Conduct FAQ](https://github.com/Azure/multi-cloud-asset-inventory-preview/blob/main/CODE_OF_CONDUCT.md) or contact opencode@microsoft.com with any additional questions or comments.
