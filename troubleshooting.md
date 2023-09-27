## Troubleshooting
This step can be used when you are not seeing AWS resources that should be onboarded showing in Azure.
```
az rest --method get --url https://management.azure.com/subscriptions/${subscriptionId}/resourceGroups/aws-asset-management-rg/providers/Microsoft.HybridConnectivity/publicCloudConnectors/aws-connector-${awsAccountId}/providers/Microsoft.HybridConnectivity/solutionConfigurations/aws-asset-management?api-version=2023-04-01-preview --verbose
```

If AWS resources are showing under the resource group "aws_${awsAccountId}", it means the onboarding is successful; if not, it is not successful and please file a GitHub Issue.
