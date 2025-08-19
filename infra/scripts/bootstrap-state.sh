#!/usr/bin/env bash
set -euo pipefail

# Bootstrap an Azure Storage account for Terraform remote state.
# Usage:
#   ./bootstrap-state.sh <subscription_id> <resource_group> <storage_account> <container> <location>

sub=${1:-}
rg=${2:-}
sa=${3:-}
container=${4:-}
loc=${5:-}

if [[ -z "$sub" || -z "$rg" || -z "$sa" || -z "$container" || -z "$loc" ]]; then
  echo "Usage: $0 <subscription_id> <resource_group> <storage_account> <container> <location>" 1>&2
  exit 1
fi

echo "Setting subscription: $sub"
az account set --subscription "$sub"

echo "Creating resource group: $rg"
az group create -n "$rg" -l "$loc" >/dev/null

echo "Creating storage account: $sa"
az storage account create -n "$sa" -g "$rg" -l "$loc" --sku Standard_LRS --encryption-services blob >/dev/null

key=$(az storage account keys list -g "$rg" -n "$sa" --query "[0].value" -o tsv)

echo "Creating blob container: $container"
az storage container create --name "$container" --account-name "$sa" --account-key "$key" >/dev/null

echo "Done. Configure backend as:\nbackend \"azurerm\" { resource_group_name = \"$rg\" storage_account_name = \"$sa\" container_name = \"$container\" key = \"tfstate/dev.tfstate\" }"
