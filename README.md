# Multi-cloud Asset Inventory Management

Multi-cloud asset inventory management allows you to see an up-to-date view of your resources from other public clouds in Azure. This will enable you to see all cloud resources in a single place. In addition, you can query for all your cloud resources through Azure Resource Graph. WWhen the assets are represented in Azure, we pull all the metadata from the source cloud along with tags in the source cloud. For instance, if you need to query for resources with a certain tag (from Azure or AWS), you can do so with multi-cloud asset inventory.  Asset Management will scan your AWS account at configured periodic interval default to 1 hour. to ensure we have a complete, correct view represented in Azure.

With this private preview feature, you can onboard AWS EC2 instances, S3 buckets and Lambda functions to Azure as multi-cloud asset inventories, new resources created in your AWS account will also be automatically connected to Azure. 

- Please do <code style="color : red">NOT</code> try this feature in production environments.
  
- Please do <code style="color : red">NOT</code> try this feature if you are already using a connector from Microsoft Defender for Cloud (MDC) to onboard your AWS/GCP resources to Azure Arc in production environments.

- Arc-enabled EC2 Instance: If your machine is already onboarded to Arc, you <code style="color : red">CANNOT</code> see this in Multi-cloud Asset Inventory at this time.

[Multi-cloud asset inventory management with a single account](https://github.com/Azure/azure-arc-publicclouds-preview/blob/main/preview/multi-cloud-asset-inventory-management-with-singleacct.md)

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft 
trademarks or logos is subject to and must follow 
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
