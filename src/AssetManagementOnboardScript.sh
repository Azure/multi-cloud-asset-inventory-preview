#!/bin/bash
# Asset Management onboard script v1.0

# RP registration 
registerRPs()
{
    echo
    echo "INFO: Registering Microsoft.HybridConnectivity and Microsoft.AwsConnector resource providers. This process may take 5-10 minutes."

    # Register resource providers    
    az provider register -n Microsoft.HybridConnectivity 2>/dev/null
    az provider register -n Microsoft.AwsConnector 2>/dev/null

    iteration=0
    while true; do
        registrationStateHybridConnectivity=`az provider show -n Microsoft.HybridConnectivity --query registrationState --output tsv`
        registrationStateAwsConnector=`az provider show -n Microsoft.AwsConnector --query registrationState --output tsv`

        if [[ "$registrationStateHybridConnectivity" == "Registered" &&  "$registrationStateAwsConnector" == "Registered" ]]; then
            break
        else
            iteration=$((iteration+1))
            if [ "$iteration" -gt 15 ]; then
                echo "ERROR: Resource provider registration timedout / failed. Please try again later."
                exit 1
            fi

            echo "INFO: Awaiting completion of resource provider registration. Sleeping for 1 minute before retrying."
            sleep 60
        fi
    done

    echo "INFO: Resource provider registration is now complete for Microsoft.HybridConnectivity and Microsoft.AwsConnector."
}

# Feature flag registration
registerFeatureFlags()
{
    echo
    echo "INFO: Registering feature flags. This process may take 5-10 minutes."

    iteration=0
    
    while true; do
        featureFlagStatusHybridConnectivity=`az feature register --namespace Microsoft.HybridConnectivity --name publicCloudPreviewAccess --query properties.state --output tsv 2>/dev/null`
        featureFlagStatusAwsConnector=`az feature register --namespace Microsoft.AwsConnector --name publicCloudPreviewAccess --query properties.state --output tsv 2>/dev/null`

        if [[ "$featureFlagStatusHybridConnectivity" == "Registered" && "$featureFlagStatusAwsConnector" == "Registered" ]]; then 
            registrationStateHybridConnectivity=`az provider show -n Microsoft.HybridConnectivity --query registrationState --output tsv`
            registrationStateAwsConnector=`az provider show -n Microsoft.AwsConnector --query registrationState --output tsv`

            break
        else
            iteration=$((iteration+1))
            if [ "$iteration" -gt 15 ]; then
                echo "ERROR: Feature flag registration timedout / failed. Please try again later."
                exit 1
            fi

            echo "INFO: Awaiting completion of feature flag registration. Sleeping for 1 minute before retrying."
            sleep 60
        fi
    done

    echo "INFO: Feature flag registration is now complete."
}

# Create AWS Connector
createAWSConnector()
{
    echo
    connectorUri=https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.HybridConnectivity/publicCloudConnectors/$publicCloudConnectorName
    echo "INFO: Creating ARM resource for public cloud connector: $connectorUri"

    publicCloudConnectorState=`az rest --method put --url $connectorUri?api-version=2023-04-01-preview --header "content-type=application/json" --body '{"location":"'$azureLocation'","properties":{"hostType":"AWS","awsCloudProfile":{"accountId": "'$awsAccountId'"}}}' --query properties.provisioningState --output tsv`

    if [[ "$publicCloudConnectorState" == "Succeeded" ]]; then
        echo "INFO: Public cloud connector resource created successfully."
    else
        echo "FAILED: Error occurred while public cloud connector resource."

        exit 1
    fi
}

# Create SolutionConfiguration
createSolutionConfiguration()
{
    echo
    solutionConfigurationUri=https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.HybridConnectivity/publicCloudConnectors/$publicCloudConnectorName/providers/Microsoft.HybridConnectivity/solutionConfigurations/$solutionConfigurationName

    echo "INFO: Creating solution configuration resource: $solutionConfigurationUri"

    solutionConfigurationState=`az rest --method put --url $solutionConfigurationUri?api-version=2023-04-01-preview --header "content-type=application/json" --body '{"properties":{"solutionType":"Microsoft.AssetManagement","solutionSettings":{"cloudProviderServiceTypes":"'$awsServicesToImport'", "periodicSyncTime":"'$periodicSyncTime'", "periodicSync":"'$periodicSync'"}}}' --query properties.provisioningState --output tsv`

    if [[ "$solutionConfigurationState" == "Succeeded" ]]; then
        echo "INFO: Successfully created solution configuration resource."
    else
        echo "FAILED: Error occurred while creating solution configuration resource."

        exit 1
    fi
}

invalidConfiguration()
{
    configEnvName="$1"

    echo
    echo "FATAL: $configEnvName IS NOT DEFINED. Please check the configuration values and try again."
    exit 2
}

checkConfiguration()
{
    # Check the configuration values
    if [ -z ${subscriptionId+x} ]; then invalidConfiguration "subscriptionId"; else echo "INFO: subscriptionId: '$subscriptionId'"; fi

    if [ -z ${resourceGroupName+x} ]; then invalidConfiguration "resourceGroupName"; else echo "INFO: resourceGroupName: '$resourceGroupName'"; fi

    if [ -z ${azureLocation+x} ]; then invalidConfiguration "azureLocation"; else echo "INFO: azureLocation: '$azureLocation'"; fi

    if [ -z ${publicCloudConnectorName+x} ]; then invalidConfiguration "publicCloudConnectorName"; else echo "INFO: publicCloudConnectorName: '$publicCloudConnectorName'"; fi

    if [ -z ${solutionConfigurationName+x} ]; then invalidConfiguration "solutionConfigurationName"; else echo "INFO: solutionConfigurationName: '$solutionConfigurationName'"; fi

    if [ -z ${awsAccountId+x} ]; then invalidConfiguration "awsAccountId"; else echo "INFO: awsAccountId: '$awsAccountId'"; fi

    if [ -z ${awsServicesToImport+x} ]; then invalidConfiguration "awsServicesToImport"; else echo "INFO: awsServicesToImport: '$awsServicesToImport'"; fi

    if [ -z ${periodicSync+x} ]; then invalidConfiguration "periodicSync"; else echo "INFO: periodicSync: '$periodicSync'"; fi

    if [ -z ${periodicSyncTime+x} ]; then invalidConfiguration "periodicSyncTime"; else echo "INFO: periodicSyncTime: '$periodicSyncTime'"; fi
}

# Read configuration values
checkConfiguration

# Set the account
az account set -s $subscriptionId

# Register RPs
registerRPs

# Register feature flags
registerFeatureFlags

# Create ARM resources
createAWSConnector
createSolutionConfiguration

# read tenantId
azure_user_tenant_id=$(az account show | grep -o '"tenantId": "[^"]*' | cut -d'"' -f4)

# resource group name where AWS resources will be imported
aws_resource_group_name="/subscriptions/$subscriptionId/resourceGroups/aws_$awsAccountId"

# Print next steps
echo
echo "                      !!!!!!!! Action required !!!!!!!!"
echo
echo "PLEASE UPLOAD THE AWS CLOUDFORMATION TEMPLATE from https://aka.ms/AwsAssetManagementProd TO AWS ACCOUNT $awsAccountId" 
echo
echo "Please use PublicCloudConnectorAzureTenantId as $azure_user_tenant_id"
echo
echo "After AWS CloudFormation template is successfully deployed, AWS resources will be imported into $aws_resource_group_name resource group in Azure."
echo
echo "                      !!!!!!!! Action required !!!!!!!!"
echo
