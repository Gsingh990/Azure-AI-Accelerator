# Architecture Overview

This accelerator provides a Terraform-first approach to deploying Azure AI solutions with a thin web UI and API for user-driven provisioning.

- Terraform modules model enterprise concerns: identity, networking, security, observability, and AI services.
- Azure AI Foundry (Hub + Project) is provisioned using the `azapi` provider to target the latest ARM API versions until native provider support matures.
- Azure OpenAI is provisioned via `azurerm_cognitive_account` (kind `OpenAI`) with optional model deployments using `azapi`.
- Optional App Service hosts a minimal backend API that runs Terraform and serves a static frontend.

Key design tenets

- Separation of concerns: reusable modules + thin environment compositions
- Security by default: RBAC, Key Vault, diagnostics, and optional private networking
- Portability: avoid brittle scripts; rely on providers and documented inputs/outputs
- CI-ready: consistent layouts for dev/test/prod with clear tfvars

See `infra/` for module details and `frontend/` + `backend/` for the minimal UI/API.

## Identity Model

- System-assigned Managed Identity (MI) on App Service web apps (frontend/backend) for secretless auth.
- Azure AI Foundry Hub/Project created with identity to enable future RBAC bindings.
- Key Vault uses RBAC authorization (no access policies); access is granted via Azure roles.
- Role assignments (per environment):
  - Backend MI → `Cognitive Services OpenAI User` on the AOAI account scope
  - Backend MI → `Key Vault Secrets User` on the Key Vault scope

This enables the backend or any in‑VNet workload to call Azure OpenAI and read secrets without embedding credentials.

## Network Topology (Private by Default)

- Virtual Network with subnets:
  - `app`: for application components (optional)
  - `data`: for data services (optional)
  - `privatelink`: dedicated for Private Endpoints
- Private Endpoints (PE):
  - Azure OpenAI (Cognitive Services): subresource `account`
  - Key Vault: subresource `vault`
  - Storage (Blob): subresource `blob`
- Private DNS Zones linked to the VNet:
  - `privatelink.cognitiveservices.azure.com`
  - `privatelink.vaultcore.azure.net`
  - `privatelink.blob.core.windows.net`

Name resolution inside the VNet resolves service hostnames to the Private Endpoint IPs. Public network access is disabled wherever supported (e.g., AOAI), limiting access to private networks only.

## Provisioning and Execution Flow

1. User submits requirements in the web UI (name/prefix, environment, region, services, models).
2. Backend API writes tfvars and runs `terraform init/plan/apply` in the chosen environment directory.
3. Terraform composes reusable modules to provision:
   - Core (RG, Log Analytics, Key Vault with RBAC)
   - Network + Private DNS + Private Endpoints
   - Azure AI Foundry Hub + Project (via `azapi`)
   - Azure OpenAI account + model deployments (via `azapi`)
   - Optional App Service for the UI/API with System-assigned MI
4. At runtime, the backend MI acquires tokens using Managed Identity and calls Azure OpenAI over the private network; DNS resolves AOAI endpoint to the PE IP.

## Regions

- Default region is `eastus`, configurable per environment and via the UI. Ensure chosen regions have capacity and access to requested AOAI models.

## Extensibility

- Additional model providers (e.g., Mistral, Llama, Cohere) can be integrated via Azure AI Foundry Model Catalog resources. UI already exposes a provider selector; Terraform modules can be extended to provision provider-specific endpoints and credentials (if required) securely via Key Vault.

## CI/CD

- Root GitHub Actions workflow plans the `dev` environment on changes under `AI_Accelerator/infra/**`.
- Recommended enhancements: `terraform fmt -check`, `terraform validate`, per‑env plan jobs, and protected apply stages.
