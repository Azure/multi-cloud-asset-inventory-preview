#!/bin/bash
# Asset Management offboard script v1.0

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

    if [ -z ${awsAccountId+x} ]; then invalidConfiguration "awsAccountId"; else echo "INFO: awsAccountId: '$awsAccountId'"; fi
}

initConfiguration()
{
    # resource group name that holds the publiccloudconnector and solutionconfigurations.
    resourceGroupName="aws-asset-management-rg"
}

# Delete resource group
deleteResourceGroup()
{
    rgName="$1"

    echo
    # Create resource group
    echo "INFO: Deleting resource group: '$rgName'."
    
    rgDeleteCmd="az group delete -n $rgName -y"
    if [ "$args_w" = true ]; then
        echo "INFO: Awaiting the deletion of all ARM resources. This process may take a few minutes."
    else
        echo "INFO: Proceeding without waiting for all ARM resources to delete."
        
        rgDeleteCmd="$rgDeleteCmd --no-wait"
    fi

    returnVal=$(eval $rgDeleteCmd 2>&1)
    if [[ "$returnVal" != *"ResourceGroupNotFound"* ]]; then
		echo "WARN: Resource group: '$rgName' deletion failed with error: $returnVal. Please ensure that you have the required permissions to delete resource groups."
        echo "WARN: Continue with the script execution."
	else
        echo "INFO: Resource group: '$rgName' is deleted successfully."
    fi
}

# Function to display help message
function display_help() {
    echo "Usage: $0 [-w]"
    echo "  -w  Wait for all resources to be deleted"
    echo "  --help   Display this help message"
    exit 0
}

# Start of the script execution
echo
echo "Asset Management Offboard script"
echo

# Initialize variables
args_w=false

# Check for arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -w)
            args_w=true
            ;;
        --help)
            # Display help message
            display_help
            ;;
        *)
            # Unknown option, display error
            echo "Error: Unknown option '$1'"
            display_help
            ;;
    esac
    shift
done

# Set the account
az account set -s $subscriptionId

# Read configuration values
readConfiguration

# Initialize configuration values
initConfiguration

# Delete Resource Group
deleteResourceGroup $resourceGroupName
deleteResourceGroup "aws_$awsAccountId"

# Print next steps
echo
echo "                      !!!!!!!! Action required !!!!!!!!"
echo
echo "PLEASE DELETE THE AWS CLOUDFORMATION TEMPLATE from AWS ACCOUNT $awsAccountId" 
echo
echo "                      !!!!!!!! Action required !!!!!!!!"
echo
