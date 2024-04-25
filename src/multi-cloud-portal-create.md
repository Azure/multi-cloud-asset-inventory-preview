# Multi-cloud Connector onboarding via Portal
We have portal support under this flight link here: https://aka.ms/multicloudprivateflight 

To get to the experience, you first need to browse Azure Arc in the Azure portal. 
![ArcBasics](https://github.com/Azure/multi-cloud-asset-inventory-preview/blob/main/images/ArcBrowse.png)

Next, navigate to the `Connectors` blade under `Management` in the table of contents within in the Azure Arc portal and click Create.
![ConnectorBrowse](https://github.com/Azure/multi-cloud-asset-inventory-preview/blob/main/images/ConnectorsBrowse.png)

Fill out the basic details of your connector with your AWS Account Id. We will support Orgnization Accounts soon. See [here](src/Connector-details.md) for more information on the Connector details.
![Bascis](https://github.com/Azure/multi-cloud-asset-inventory-preview/blob/main/images/BasicsCreate.png)

Next, configure the Multi-cloud solutions you are interested in by turning them on and configuring them. For more information on the solutions and the settings, see here:
- [Inventory](src/Inventory-Details.md)
- [ArcOnboarding](src/Arc-onboarding-details.md)
![SolutionCreate](https://github.com/Azure/multi-cloud-asset-inventory-preview/blob/main/images/SolutionsCreate.png)

Next, following the instructions to upload your Cloud Formation Temaplte on AWS. For more information, see [here](src/Connector-details.md#authentication-via-aws-cloud-formation-templates)
![SolutionCreate](https://github.com/Azure/multi-cloud-asset-inventory-preview/blob/main/images/templateCreate.png)

Next, add any tags on your Connector resource and then click Review and Create. Your Connector and Solutions will be created and the import should scan within an hour. For next steps, 
- [Query for your inventory](https://github.com/Azure/multi-cloud-asset-inventory-preview/blob/main/view-and-query-asset-inventory.md).
- [Add Management Solutions on your EC2 Arc-enabled VMs](https://learn.microsoft.com/azure/azure-arc/servers/overview#supported-cloud-operations)


