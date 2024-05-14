# Multicloud Inventory

## Overview
Multicloud Inventory allows you to see an up-to-date view of your resources from other public clouds in Azure, providing you with a single place to see all of your cloud resources. In addition, you can query for all your cloud resources through Azure Resource Graph. When the assets are represented in Azure, metadata from the source cloud is also included. For instance, if you need to query all of your Azure and AWS resources with a certain tag, you can do so with multi-cloud asset inventory. The Inventory solution will scan your source cloud on a periodic basis to ensure a complete, correct view is represented in Azure. You can also apply Azure tags or Azure policies on these resources.

## Supported AWS Resources
Today, the following items are scanned and represented in Azure. When creating the Inventory solution, you can pick and choose which AWS Services you would like to scan. We do not support choosing individual resource types at this time (only at the service level)

| AWS Service  | AWS resource type  | Azure Namespace |
|--------------|--------------------|--------------------------------------|
| API Gateway   | apiGatewayRestApis     | Microsoft.AwsConnector/apiGatewayRestApis|
| API Gateway   | apiGatewayStages     | Microsoft.AwsConnector/apiGatewayStages|
| Application AutoScaling   | applicationAutoScalingScalableTargets     | Microsoft.AwsConnector/applicationAutoScalingScalableTargets|
| Cloud Formation   | cloudFormationStacks     | Microsoft.AwsConnector/cloudFormationStacks|
| Cloud Formation   | cloudFormationStackSets     | Microsoft.AwsConnector/cloudFormationStackSets|
| Cloud Trail   | cloudTrailTrails     | Microsoft.AwsConnector/cloudTrailTrails|
| Cloud Watch   | cloudWatchAlarms     | Microsoft.AwsConnector/cloudWatchAlarms|
| Dynamo DB    | dynamoDBTables     | Microsoft.AwsConnector/dynamoDBTables|
| Dynamo DB    | dynamoDBTables     | Microsoft.AwsConnector/dynamoDBTables|
| Dynamo DB    | dynamoDBTables     | Microsoft.AwsConnector/dynamoDBTables|
| Dynamo DB    | dynamoDBTables     | Microsoft.AwsConnector/dynamoDBTables|
| Dynamo DB    | dynamoDBTables     | Microsoft.AwsConnector/dynamoDBTables|
| EC2    | ec2Instances    | Microsoft.HybridCompute/machines/EC2InstanceId/Microsoft.AwsConnector/Ec2Instances|
| EC2    | ec2KeyPairs    | Microsoft.AwsConnector/ec2KeyPairs|
| EC2    | ec2Subnets    | Microsoft.AwsConnector/ec2Subnets|
| EC2    | ec2Volumes   | Microsoft.AwsConnector/ec2Volumes|
| EC2    | ec2VPCs  | Microsoft.AwsConnector/ec2VPCs|
| EC2    | ec2NetworkAcls  | Microsoft.AwsConnector/ec2NetworkAcls|
| EC2    | ec2NetworkInterfaces| Microsoft.AwsConnector/ec2NetworkInterfaces|
| EC2    | ec2RouteTables | Microsoft.AwsConnector/ec2RouteTables|
| EC2    | ec2VPCEndpoints | Microsoft.AwsConnector/ec2VPCEndpoints|
| EC2    | ec2VPCPeeringConnections | Microsoft.AwsConnector/ec2VPCPeeringConnections|
| EC2    | ec2InstanceStatuses | Microsoft.AwsConnector/ec2InstanceStatuses|
| EC2    | ec2SecurityGroups | Microsoft.AwsConnector/ec2SecurityGroups|
| ECR   | ecrRepositories     | Microsoft.AwsConnector/ecrRepositories|
| ECS   | ecsClusters     | Microsoft.AwsConnector/ecsClusters|
| ECS   | ecsServices     | Microsoft.AwsConnector/ecsServices|
| ECS   | ecsTaskDefinitions     | Microsoft.AwsConnector/ecsTaskDefinitions|
| EFS   | efsFileSystems     | Microsoft.AwsConnector/efsFileSystems|
| EFS   | efsMountTargets     | Microsoft.AwsConnector/efsMountTargets|
| Elastic Beanstalk   | elasticBeanstalkEnvironments     | Microsoft.AwsConnector/elasticBeanstalkEnvironments|
| Elastic Load Balancer V2    | elasticLoadBalancingV2LoadBalancers| Microsoft.AwsConnector/elasticLoadBalancingV2LoadBalancers|
| Elastic Load Balancer V2    | elasticLoadBalancingV2Listeners| Microsoft.AwsConnector/elasticLoadBalancingV2Listeners|
| Elastic Load Balancer V2    | elasticLoadBalancingV2TargetGroups| Microsoft.AwsConnector/elasticLoadBalancingV2TargetGroups|
| Elastic Search   | elasticsearchDomains | Microsoft.AwsConnector/elasticsearchDomains|
| GuardDuty   | guardDutyDetectors | Microsoft.AwsConnector/guardDutyDetectors|
| IAM   | iamGroups | Microsoft.AwsConnector/iamGroups|
| IAM   | iamManagedPolicies | Microsoft.AwsConnector/iamManagedPolicies|
| IAM   | iamServerCertificates | Microsoft.AwsConnector/iamServerCertificates|
| IAM   | iamUserPolicies | Microsoft.AwsConnector/iamUserPolicies|
| IAM   | iamVirtualMFADevices | Microsoft.AwsConnector/iamVirtualMFADevices|
| KMS   | kmsKeys | Microsoft.AwsConnector/kmsKeys|
| Lambda   | lambdaFunctions | Microsoft.AwsConnector/lambdaFunctions|
| License Manager   | licenseManagerLicenses | Microsoft.AwsConnector/licenseManagerLicenses|
| Lightsail   | lightsailInstances | Microsoft.AwsConnector/lightsailInstances|
| Lightsail   | lightsailBuckets| Microsoft.AwsConnector/lightsailBuckets|
| Logs   | logsLogGroups | Microsoft.AwsConnector/logsLogGroups|
| Logs   | logsLogStreams | Microsoft.AwsConnector/logsLogStreams|
| Logs   | logsMetricFilters | Microsoft.AwsConnector/logsMetricFilters|
| Logs   | logsSubscriptionFilters | Microsoft.AwsConnector/logsSubscriptionFilters|
| Macie   | macieAllowLists | Microsoft.AwsConnector/macieAllowLists|
| Network Firewalls   | networkFirewallFirewalls | Microsoft.AwsConnector/networkFirewallFirewalls|
| Network Firewalls   | networkFirewallFirewallPolicies | Microsoft.AwsConnector/networkFirewallFirewallPolicies|
| Network Firewalls   | networkFirewallRuleGroups | Microsoft.AwsConnector/networkFirewallRuleGroups|
| OpenSearch   | openSearchServiceDomains | Microsoft.AwsConnector/openSearchServiceDomains|
| Organization   | organizationsAccounts | Microsoft.AwsConnector/organizationsAccounts|
| Organization   | organizationsOrganizations | Microsoft.AwsConnector/organizationsOrganizations|
| RDS   | rdsDBInstances | Microsoft.AwsConnector/rdsDBInstances|
| RDS   | rdsDBClusters | Microsoft.AwsConnector/rdsDBClusters|
| RDS   | rdsEventSubscriptions | Microsoft.AwsConnector/rdsEventSubscriptions|
| Redshift   | redshiftClusters | Microsoft.AwsConnector/redshiftClusters|
| Redshift   | redshiftClusterParameterGroups | Microsoft.AwsConnector/redshiftClusterParameterGroups|
| Route 53   | route53HostedZones | Microsoft.AwsConnector/route53HostedZones|
| SageMaker  | sageMakerApps | Microsoft.AwsConnector/sageMakerApps|
| SageMaker   | sageMakerDevices | Microsoft.AwsConnector/sageMakerDevices|
| SageMaker   | sageMakerImages | Microsoft.AwsConnector/sageMakerImages|
| S3   | s3Buckets | Microsoft.AwsConnector/s3Buckets|
| S3   | s3BucketPolicies | Microsoft.AwsConnector/s3BucketPolicies|
| S3   | s3AccessPoints | Microsoft.AwsConnector/s3AccessPoints|
| SNS   | snsTopics | Microsoft.AwsConnector/snsTopics|
| SQS   | sqsQueues | Microsoft.AwsConnector/sqsQueues|
| WAFV2  | wafv2IPSets | Microsoft.AwsConnector/wafv2IPSets|
| WAFV2  | wafv2WebACLAssociations | Microsoft.AwsConnector/wafv2WebACLAssociations|


## Supported Regions

In Azure, you will need to create solution in one of the supported Azure regions below: 
- East US, West US Central, Canada Central, West Europe

In AWS, we will scan for resources in the following regions: 
- us-east-1, us-east-2, us-west-1, us-west-2, ca-central-1, ap-southeast-1, ap-southeast-2, ap-northeast-1, ap-northeast-3, eu-west-1, eu-west-2, eu-central-1, eu-north-1, sa-east-1

## Unsupported scenarios
For EC2 instances that already have the Arc agent, please do not use the inventory solution. This will create a duplicate record of the EC2 instance in Azure. We are planning on supporting existing EC2 VMs with the Arc agent installed and just reusing the existing resource for inventory. 

## Modeling AWS resources in Azure
When you onboard to Multicloud Inventory, our service will create a new resource group with the following naming convention: aws_yourAwsAccountId
All of the discovered resources will be placed in that resource group. Also, all of the scanned items will be resources in Azure under the AwsConnector namespace. You can apply Azure tags and policies to these resources.

In addition, for resources that are discovered in AWS and projected in Azure, the resource will need an Azure region. Here is the logic for how we will map: 
|AWS Region |Mapped Azure Region |
|--|--|
|us-east-1 | EastUS |
|us-east-2 | EastUS |
|us-west-1 | EastUS |
|us-west-2 | EastUS |
|ca-central-1 | EastUS |
|ap-southeast-1 | SoutheastAsia |
|ap-northeast-1 | SoutheastAsia |
|ap-northeast-3 | SoutheastAsia |
|ap-southeast-2 | AU East |
|eu-west-1 | West Europe |
|eu-central-1 | West Europe |
|eu-west-2 | UK South |
|sa-east-1 | Brazil South |
     
## Periodic Sync Time
The periodic sync time determines how often your AWS account is scanned and synced to Azure. Any time there is a change in AWS for your resource, that change will be reflected in Azure. For instance, if a resource is deleted on AWS, that resoruce will be deleted in Azure. We want to create a source of truth inventory that is up to date with your source cloud. 

If do not want the Inventory solution to scan your account, you can turn off the periodic sync time through the API.

## Querying for resources in Azure Resource Graph
Please see [view and query asset inventory](https://github.com/Azure/multi-cloud-asset-inventory-preview/blob/main/view-and-query-asset-inventory.md).

## Offboarding
If you delete the Connector or the Inventory solution, your AWS resources represented in Azure will still remain. You can clean them up by browsing to the resource group under aws_yourAwsAccountId and deleting that resource group. After the solution is deleted, the periodic syncs will stop and your resources will not be updated in Azure. It is recommended to clean them up so you do not look at stale inventory data. 

## Support
Please see our [support policy](https://github.com/Azure/multi-cloud-asset-inventory-preview/blob/main/SUPPORT.md).
