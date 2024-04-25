# Multi-cloud Arc Onboarding

## Overview
Arc Onboarding auto-discovers EC2 instances running in your AWS environment and installs the Arc agent on the VMs. This simplified experience will enable customers to onboard to Azure management services such as Azure Monitor, providing a centralized way for customers to manage their Azure and AWS VMs.

Your AWS VMs must have the SSM agent installed in order for the Arc Agent installation to succeed.

## Supported Regions
In Azure, you will need to create solution in one of the supported Azure regions below: 
- West US 2, South Central US, UK South, Southeast Asia, West Europe, Esat US, Australia East, East US 2, North Europe, West US 3, Sweden Central, Finland Central

In AWS, we will scan for EC2 instances in the following regions. You are able to filter for specific regions if you do not want to scan all of them.
- us-east-1, us-east-2, us-west-1, us-west-2, ca-central-1, ap-southeast-1, ap-southeast-2, ap-northeast-1, ap-northeast-3, eu-west-1, eu-west-2, eu-central-1, eu-north-1, sa-east-1

## Modeling AWS resources in Azure
When you onboard to Multi-cloud Arc Onboarding, our service will create a new resource group with the following naming convention: aws_yourAwsAccountId
All of the discovered resources will be placed in that resource group. Also, all of the scanned items will be resources in Azure under the AwsConnector namespace. You can apply Azure tags and policies to these resources.

## Filtering Rules
You can filter for which Azure regions you would like to scan for. By default, all regions will be scanned. 

In addition, you must have a tag on your EC2 instances with the key of `Arc` and empty value. If your EC2 instance does not have this tag, the Arc agent will not be installed.

## Connectivity Method
You can select how the Arc Connected machine agent should connect through the internet through either public endpoints or through a proxy server. You can learn more [here](https://learn.microsoft.com/azure/azure-arc/servers/network-requirements)

## Periodic Sync Time
The periodic sync time determines how often your AWS account is scanned and synced to Azure. Any time there is a newly discovered AWS instance that fit the filtering rules, the Arc agent will be installed automatically. 

If do not want the Arc Onboarding solution to scan your account, you can turn off the periodic sync time through the API.

## Offboarding
If you delete the Connector or the Arc Onboarding solution, your AWS EC2 instances will remain in Azure as Arc-enabled servers. You can clean them up by browsing to the resource group under aws_yourAwsAccountId and deleting that resource group. After the solution is deleted, the periodic syncs will stop the auto-detection of new EC2 instances and the Arc agent will not be installed.

## Support
Please see our [support policy](https://github.com/Azure/multi-cloud-asset-inventory-preview/blob/main/SUPPORT.md).