# Using the Terraform Stacks

## Prereqs

- Terraform >= 1.5
- Azure CLI >= 2.50
- Azure subscription with access to create Cognitive Services and AI Foundry resources

## Auth

- Service Principal (recommended for CI):
  - `az ad sp create-for-rbac --name <name> --role Owner --scopes /subscriptions/<sub>`
  - export `AZURE_TENANT_ID`, `AZURE_CLIENT_ID`, `AZURE_CLIENT_SECRET`, `AZURE_SUBSCRIPTION_ID`
- Or use `az login` locally with your user and rely on Azure CLI auth

## Remote State (optional but recommended)

- `cd infra/scripts`
- `./bootstrap-state.sh <sub> tfstate-rg <uniqueacctname> tfstate <region>`
- Edit `infra/environments/dev/providers.tf` backend block

## Run (dev)

- `cd infra/environments/dev`
- `cp dev.tfvars.example dev.auto.tfvars`
- `terraform init`
- `terraform plan`
- `terraform apply`

## Notes

- Azure AI Foundry resources are created using `azapi` with a preview API version. You may need to update the API version as Microsoft releases updates.
- Azure OpenAI model deployments are also created via `azapi`. Ensure your subscription/region has access to requested models.
- Private endpoints and DNS are enabled by default for Azure OpenAI; access requires network connectivity to the VNet (e.g., via a jump host, VPN, or running workloads within the VNet).
