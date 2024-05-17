# Multicloud Connector onboarding via Portal
We have portal support under this flight link here: https://aka.ms/multicloudprivateflight 

To get to the experience, you first need to browse Azure Arc in the Azure portal. 
![ArcBasics](https://github.com/Azure/multi-cloud-asset-inventory-preview/blob/main/images/ArcBrowse.png)

Next, navigate to the `Connectors` blade under `Management` in the table of contents within in the Azure Arc portal and click Create.
![ConnectorBrowse](https://github.com/Azure/multi-cloud-asset-inventory-preview/blob/main/images/ConnectorsBrowse.png)

Fill out the basic details of your connector with your AWS Account Id. You can choose to connect to a Single Account or Organization Account. See [here](Connector-details.md) for more information on the Connector details and AWS account information.
![Bascis](https://github.com/Azure/multi-cloud-asset-inventory-preview/blob/main/images/BasicsCreate1.png)

Next, configure the Multicloud solutions you are interested in by turning them on and configuring them. For more information on the solutions and the settings, see here:
- [Inventory](Inventory-Details.md)
- [ArcOnboarding](Arc-onboarding-details.md)
![SolutionCreate](https://github.com/Azure/multi-cloud-asset-inventory-preview/blob/main/images/SolutionsCreate.png)

Next, download the Cloud Formation Template to be uploaded on AWS. For more information on the Cloud Formation Template, see [here](Connector-details.md#authentication-via-aws-cloud-formation-templates)
![SolutionCreate](https://github.com/Azure/multi-cloud-asset-inventory-preview/blob/main/images/templateCreate.png)

## Steps to upload template on AWS
### Create Stack (needed for Single and Organization Accounts)
1. Log into the AWS Console and [Create Stack](https://aka.ms/PublicCloudAwsCloudFormation) by navigating to AWS management console --> CloudFormation --> Stack --> Create Stack with new resources
2. Upload your template by choosing Template is ready --> Upload a template file
   ![StackCreate](https://github.com/Azure/multi-cloud-asset-inventory-preview/blob/main/images/stackcreate.jpg)
3. In the next step, specify a stack name. Leave everything else as default.
   ![StackCreate2](https://github.com/Azure/multi-cloud-asset-inventory-preview/blob/main/images/stack2.png)
4. Confirm the information is correct and check "I acknowledge ..". Click Submit
   ![StackCreate3](https://github.com/Azure/multi-cloud-asset-inventory-preview/blob/main/images/submitstack.jpg)

### Create StackSet (needed for Organization Accounts)
You need to complete the following steps if you are using an Organization account. 
1. Log into the AWS Console and [Create StackSet](https://aka.ms/MultiCloudStackSetCreate) by navigating to AWS management console --> CloudFormation --> StackSet --> Create StackSet
2. Leave the default settings and upload the template
   ![StackSetCreate](https://github.com/Azure/multi-cloud-asset-inventory-preview/blob/main/images/stacksetcreate.png)
3. Update the StackSet details and use `AzureArcMultiCloudStackset` as the StackSet name
   ![StackSetCreate2](https://github.com/Azure/multi-cloud-asset-inventory-preview/blob/main/images/stacksetcreate21.png)
4. Choose your orgnization account to deploy to.
5. Choose an AWS region to deploy the Stack to. This can be any region. Leave everything else with the default values. 
   ![StackSetCreate3](https://github.com/Azure/multi-cloud-asset-inventory-preview/blob/main/images/stackset3.png)
6. Confirm the information is correct and check "I acknowledge ..". Click Submit

> [!NOTE]
> If you have selected Arc Onboarding solution, you will also need to ensure you have met the [prereqs](Inventory-Details.md)


Next, add any tags on your Connector resource and then click Review and Create. Your Connector and Solutions will be created and the import should scan within an hour. For next steps, 
- [Query for your inventory](https://github.com/Azure/multi-cloud-asset-inventory-preview/blob/main/view-and-query-asset-inventory.md).
- [Add Management Solutions on your EC2 Arc-enabled VMs](https://learn.microsoft.com/azure/azure-arc/servers/overview#supported-cloud-operations)


