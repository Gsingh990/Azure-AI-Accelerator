# Terraform Structure

- `modules/`: Reusable, versioned modules for core platform building blocks and AI services
- `environments/`: Thin compositions per environment (dev/test/prod) consuming modules with tfvars
- `scripts/`: Utility scripts (e.g., remote state bootstrap)

## Providers and State

- Uses `azurerm` for Azure resources and `azapi` for preview/unsupported types (AI Foundry hub/project, OpenAI deployments)
- Remote state: Azure Storage backend (script provided). You can use local state for initial trials.

## Modules

- `core`: Resource group, Key Vault, Log Analytics, diagnostics
- `network`: VNet, subnets, optional private endpoints
- `storage`: Storage account(s) for data and state
- `openai`: Azure OpenAI (Cognitive Services) + optional model deployments, private endpoint + DNS (default on)
- `ai_foundry`: Azure AI Foundry Hub + Project via `azapi`
- `app`: App Service Plan + Web Apps (optional, for the included UI/API)

Check each module's `variables.tf` for inputs and `outputs.tf` for outputs.
