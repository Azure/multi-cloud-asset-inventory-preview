#!/bin/bash
# Asset Management onboard script v1.0

# RP registration 
registerRPs()
{
    echo
    echo "INFO: Registering Microsoft.HybridConnectivity, Microsoft.GCPConnector and Microsoft.HybridCompute resource providers. This process may take 5-10 minutes."

    # Register resource providers    
    az provider register -n Microsoft.HybridConnectivity 2>/dev/null
    az provider register -n Microsoft.GCPConnector 2>/dev/null
    az provider register -n Microsoft.HybridCompute 2>/dev/null

    iteration=0
    while true; do
        registrationStateHybridConnectivity=`az provider show -n Microsoft.HybridConnectivity --query registrationState --output tsv`
        registrationStateGCPConnector=`az provider show -n Microsoft.GCPConnector --query registrationState --output tsv`
        registrationStateHybridCompute=`az provider show -n Microsoft.HybridCompute --query registrationState --output tsv`

        if [[ "$registrationStateHybridConnectivity" == "Registered" &&  "$registrationStateGCPConnector" == "Registered" &&  "$registrationStateHybridCompute" == "Registered" ]]; then
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

    echo "INFO: Resource provider registration is now complete for Microsoft.HybridConnectivity, Microsoft.GCPConnector and Microsoft.HybridCompute."
}

# Feature flag registration
registerFeatureFlags()
{
    echo
    echo "INFO: Registering feature flags. This process may take 5-10 minutes."

    iteration=0
    
    while true; do
        featureFlagStatusHybridConnectivity=`az feature register --namespace Microsoft.HybridConnectivity --name hiddenGCPPreviewAccess --query properties.state --output tsv 2>/dev/null`
        featureFlagStatusGCPConnector=`az feature register --namespace Microsoft.GCPConnector --name hiddenGCPPreviewAccess --query properties.state --output tsv 2>/dev/null`

        if [[ "$featureFlagStatusHybridConnectivity" == "Registered" && "$featureFlagStatusGCPConnector" == "Registered" ]]; then
            registrationStateHybridConnectivity=`az provider show -n Microsoft.HybridConnectivity --query registrationState --output tsv`
            registrationStateGCPConnector=`az provider show -n Microsoft.GCPConnector --query registrationState --output tsv`

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

generateGCPTemplate()
{
    echo
    generateGCPTemplateUri=https://management.azure.com/subscriptions/$subscriptionId/providers/Microsoft.HybridConnectivity/generateGCPTemplate

    echo "INFO: Generating GCP template for project: $gcpProjectNumber using uri: $generateGCPTemplateUri"

    publicCloudConnectorId=/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.HybridConnectivity/publicCloudConnectors/$publicCloudConnectorName
    requestBody="{\"connectorId\":\"$publicCloudConnectorId\",\"solutionTypes\":[{\"solutionType\":\"Microsoft.AssetManagement\",\"solutionSettings\":{\"gcpServiceTypes\":\"storage,compute,cloudfunctions\",\"periodicSyncTime\":\"$periodicSyncTime\",\"periodicSync\":\"$periodicSync\"}}, {\"solutionType\":\"Microsoft.HybridCompute.Onboard\",\"solutionSettings\":{\"scalAllGCPRegions\":\"true\",\"periodicSyncTime\":\"$periodicSyncTime\",\"periodicSync\":\"$periodicSync\"}}]}"

    echo $requestBody

    gcpTemplate=`az rest --method post --url $generateGCPTemplateUri?api-version=2025-12-01-preview --header "content-type=application/json" --body "$requestBody" --query body --output json`

    if [ -z "$gcpTemplate" ]; then
        echo "ERROR: Failed to generate GCP template. Please check the input parameters and try again."
        exit 1
    fi

    modifiedTemplate=""
    in_locals=0
    brace_count=0

    while IFS= read -r line; do

        if [[ "$line" =~ \"google\"[[:space:]]*:[[:space:]]*\{\} ]]; then
            modifiedTemplate+="  \"google\": { \"project\": \"\${local.project_id}\" }"$'\n'
        continue
        fi
        # Detect start of locals block
        if [[ "$line" =~ \"locals\"[[:space:]]*:[[:space:]]*\{ ]]; then
            in_locals=1
            brace_count=1
            modifiedTemplate+="$line"$'\n'
            continue
        fi

        if [[ $in_locals -eq 1 ]]; then
            # Track braces to know when locals block ends
            open=$(grep -o '{' <<< "$line" | wc -l)
            close=$(grep -o '}' <<< "$line" | wc -l)
            brace_count=$((brace_count + open - close))

            # Replace project_id and project_number lines
            if [[ "$line" =~ \"project_id\" ]]; then
                modifiedTemplate+="    \"project_id\": \"$gcpProjectId\","$'\n'
                continue
            fi
            if [[ "$line" =~ \"project_number\" ]]; then
                modifiedTemplate+="    \"project_number\": \"$gcpProjectNumber\""$'\n'
                continue
            fi

            modifiedTemplate+="$line"$'\n'

            # End of locals block
            if [[ $brace_count -eq 0 ]]; then
                in_locals=0
            fi
            continue
        fi

        # Lines outside locals block
        modifiedTemplate+="$line"$'\n'
    done <<< "$gcpTemplate"

    # Save to main.tf.json
    echo "$modifiedTemplate" > main.tf.json
}

configureOIDCAuthOnGCP()
{
    # Install gcloud CLI (Linux x86_64)
    if ! command -v gcloud &> /dev/null; then
        echo "Installing gcloud CLI..."
        curl -sSL https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-495.0.0-linux-x86_64.tar.gz -o google-cloud-cli.tar.gz
        tar -xf google-cloud-cli.tar.gz
        ./google-cloud-sdk/install.sh -q
        source ./google-cloud-sdk/path.bash.inc
    fi

    # Authenticate (opens browser for login)
    echo "Authenticating..."
    ADC_FILE="$HOME/.config/gcloud/application_default_credentials.json"

    if [ ! -f "$ADC_FILE" ]; then
        echo "No Application Default Credentials found at $ADC_FILE."
        echo "Starting login process..."
        gcloud auth application-default login
    fi
    terraform init
    terraform plan
    terraform apply -auto-approve
}

# Create GCP Connector
createGCPConnector()
{
    echo
    connectorUri=https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.HybridConnectivity/publicCloudConnectors/$publicCloudConnectorName
    echo "INFO: Creating ARM resource for public cloud connector: $connectorUri"

    publicCloudConnectorState=`az rest --method put --url $connectorUri?api-version=2025-12-01-preview --header "content-type=application/json" --body '{"location":"'$azureLocation'","properties":{"hostType":"GCP","gcpCloudProfile":{"projectProperties": {"projectNumber": "'$gcpProjectNumber'"}}}}' --query properties.provisioningState --output tsv`

    if [[ "$publicCloudConnectorState" == "Succeeded" ]]; then
        echo "INFO: Public cloud connector resource created successfully."
    else
        echo "FAILED: Error occurred while creating public cloud connector resource."

        exit 1
    fi
}

# Create SolutionConfiguration for inventory solution
createSolutionConfigurationForInventorySolution()
{
    echo
    solutionConfigurationUri=https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.HybridConnectivity/publicCloudConnectors/$publicCloudConnectorName/providers/Microsoft.HybridConnectivity/solutionConfigurations/$inventorySolutionConfigurationName

    echo "INFO: Creating solution configuration resource for inventory solution: $solutionConfigurationUri"

    solutionConfigurationRequest="{\"properties\":{\"solutionType\":\"Microsoft.AssetManagement\",\"solutionSettings\":{\"scanAllGCPServices\":\"true\",\"gcpGlobalReadOnly\":\"true\",\"periodicSyncTime\":\"1\",\"periodicSync\":\"true\"}}}"

    solutionConfigurationState=`az rest --method put --url $solutionConfigurationUri?api-version=2025-12-01-preview --header "content-type=application/json" --body "$solutionConfigurationRequest" --query properties.provisioningState --output tsv`

    if [[ "$solutionConfigurationState" == "Succeeded" ]]; then
        echo "INFO: Successfully created solution configuration resource for inventory solution."
    else
        echo "FAILED: Error occurred while creating solution configuration resource for inventory solution."

        exit 1
    fi
}

# Create SolutionConfiguration for Arc Server solution
createSolutionConfigurationForArcServerSolution()
{
    echo
    solutionConfigurationUri=https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.HybridConnectivity/publicCloudConnectors/$publicCloudConnectorName/providers/Microsoft.HybridConnectivity/solutionConfigurations/$arcServerSolutionConfigurationName

    echo "INFO: Creating solution configuration resource for arc server solution: $solutionConfigurationUri"

    solutionConfigurationRequest="{\"properties\":{\"solutionType\":\"Microsoft.HybridCompute.Onboard\",\"solutionSettings\":{\"scanAllGCPRegions\":\"true\",\"periodicSyncTime\":\"1\",\"periodicSync\":\"true\"}}}"

    solutionConfigurationState=`az rest --method put --url $solutionConfigurationUri?api-version=2025-12-01-preview --header "content-type=application/json" --body "$solutionConfigurationRequest" --query properties.provisioningState --output tsv`

    if [[ "$solutionConfigurationState" == "Succeeded" ]]; then
        echo "INFO: Successfully created solution configuration resource for arc server solution."
    else
        echo "FAILED: Error occurred while creating solution configuration resource for arc server solution."

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

readConfiguration()
{
    # Read the configuration values
    if [ -z ${subscriptionId+x} ]; then invalidConfiguration "subscriptionId"; else echo "INFO: subscriptionId: '$subscriptionId'"; fi

    if [ -z ${gcpProjectNumber+x} ]; then invalidConfiguration "gcpProjectNumber"; else echo "INFO: gcpProjectNumber: '$gcpProjectNumber'"; fi

    if [ -z ${gcpProjectId+x} ]; then invalidConfiguration "gcpProjectId"; else echo "INFO: gcpProjectId: '$gcpProjectId'"; fi

}

initConfiguration()
{
    resourceGroupName="gcp-asset-management-rg"
    inventorySolutionConfigurationName="gcp-asset-management"
    arcServerSolutionConfigurationName="gcp-arc-server-solution"
    publicCloudConnectorName="gcp-connector-$gcpProjectNumber"
    azureLocation="eastus"
}

createResourceGroup()
{
    rgName="$1"

    echo
    # Create resource group
    echo "INFO: Creating resource group: '$rgName'."
    
    az group create -n $rgName -l $azureLocation --tags "multi-cloud-inventory" 1>/dev/null
    if [ $? -ne 0 ]; then
        echo "FATAL: resource group: '$rgName' creation failed. Please ensure that you have the required permissions to create resource groups."

        exit 1
    fi

    echo "INFO: Resource group: '$rgName' is created successfully."
}

# Start of the script execution
echo
echo "Welcome to the onboarding script for Microsoft Azure Multi-Cloud Asset Management."
echo

# Read configuration values
readConfiguration

# Set the account
az account set -s $subscriptionId
if [ $? -ne 0 ]; then
    echo "FATAL: Invalid subscription: $subscriptionId"
    exit 1
fi

# Initialize configuration values
initConfiguration

# Create Resource Group
createResourceGroup $resourceGroupName

# Register RPs
registerRPs

# Register feature flags
registerFeatureFlags

# Create ARM resources
generateGCPTemplate
configureOIDCAuthOnGCP
createGCPConnector
createSolutionConfigurationForInventorySolution
createSolutionConfigurationForArcServerSolution

# read tenantId
azure_user_tenant_id=$(az account show --query tenantId -o tsv)

# resource group name where GCP resources will be imported
gcp_resource_group_name="/subscriptions/$subscriptionId/resourceGroups/gcp_$gcpProjectNumber"

# Print next steps
echo
echo "                      !!!!!!!! Action required !!!!!!!!"
echo
echo "Please use PublicCloudConnectorAzureTenantId as $azure_user_tenant_id"
echo
echo "After GCP terraform template is successfully deployed, GCP resources will be imported into $gcp_resource_group_name resource group in Azure."
echo
echo "                      !!!!!!!! Action required !!!!!!!!"
echo