# Multicloud Connector

## Overview
The Microsoft Multicloud Connector allows customers to connect their non-Azure public cloud environments to Azure. The Connector contains the details for the AWS account that you would like to connect to. The connector object is stored under `Microsoft.HybridConnectivity/publicCloudConnector`.

## Supported Regions
In Azure, you will need to create connector in one of the supported Azure regions below: 
- East US, West US Central, Canada Central, West Europe

## Connector and Solutions
The Multicloud Connector can contain 1 or more solutions. Today, the solutions that are supported are the following: 
- [Inventory](src/Inventory-Details.md)
- [Arc Onboarding](src/Arc-onboarding-details.md)

## Authentication via AWS Cloud Formation Templates
In order for our service to connect to your AWS account, you will need to upload a Cloud Formation Template federating our OIDC provider to have access. The Cloud Formation template will request for certain permissions based on the solutions (Inventory and Arc Onboarding) that you have selected. 
- For Inventory, by default, we request Global Read to your account. However, we do support Least Priviledged Access by only requesting the read permissions of the inventory resources that you care about. This is supported through the API only right now (no portal support).
- For Arc Onboarding, our service required EC2 Write access in order to install the Arc agent. 

To learn more about Cloud Formation Template, see AWS Documentation [here](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/Welcome.html)

## Cloud Formation Template Generation
When you create the connect through the Azure portal, the Cloud Formation Template will be generated for you based on the solutions you have selected. If you are not using the Azure portal, you can call an API to generate the Cloud Formation Template. The API details will be added to this documentation soon.

## Single Account and Organization Account supported
The Multicloud Connector supports both AWS Organization Accounts and AWS Single Accounts. 

For Organization Accounts, you will need to upload the cloud formation template in two places in the AWS Cloud Formation Console. 
1. Stacks
2. StackSets (you must use the name AzureArcMultiCloudStackSet when creating the stackset)

You must upload the template in both the StackSet and the Stack in order for the template to be propagated to all of your member accounts under the Organization account. If you do not wish for the Connector to read from a certain account, you can exclude certain member accounts when you create the connector. This is supported in the API only today (no portal support).

For single accounts, you just need to create a Stack in the AWS Cloud Formation Console with the CFT template and the default parameters. 

If you make changes to your solutions, it might impact the cloud formation template. You will have to update your template in your existing Stack (and StackSet in the case you are using an Organization account) by re-uploading the newly generated CFT template. 

## Modeling AWS resources in Azure
When you onboard to Inventory and/or Arc Onboarding, our service will create a new resource group with the following naming convention: aws_yourAwsAccountId

All of the discovered resources will be placed in that resource group. Also, all of the scanned items will be resources in Azure under the AwsConnector namespace. You can apply Azure tags and policies to these resources.

If you are using an AWS Organization Account, a resource group will be created for the Organization Account and each member accounts under the Organization. 

## Authentication Status
After creating the connector and solutions, each solution will have a Status to indicate if our connection was successful with AWS. This status will be updated each time the periodic sync runs. The status strings are the following: 
- AuthenticationSuccess
- AuthenticationFailed
- AuthenticationPending

If the status is in the Failed state, please re-upload the Stack/StackSet template with the CFT template.

## Test Permissions
Customers can test the permissions ad-hoc by calling our Test Permissions API. This document will be updated with the details of how to call this API soon.

## Offboarding
If you delete the Connector, all solutions under the connector will also be deleted. However, any resources that created through Inventory or Arc Onboarding will remain. You will need to clean those up manually by browsing to the resource group under aws_yourAwsAccountId and deleting that resource group.

## Support
Please see our [support policy](https://github.com/Azure/multi-cloud-asset-inventory-preview/blob/main/SUPPORT.md).
