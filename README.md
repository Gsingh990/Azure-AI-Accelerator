# Azure AI Accelerator (Terraform-first)

Enterprise-grade accelerator to deploy AI services on Azure with Terraform as the primary IaC, plus a minimal UI to capture requirements and run plans/applies.

What it includes

- Modular Terraform: Azure AI Foundry (Hub/Project via `azapi`), Azure OpenAI, networking, storage, Key Vault, and optional App Service hosting.
- Security by default: Managed Identity, private endpoints, and private DNS; public network access disabled where supported.
- Environments: ready-to-use `dev`, `test`, and `prod` compositions.
- Minimal web UI + backend API to collect inputs and execute Terraform.
- CI-ready layout with a root GitHub Actions workflow.

See `infra/README.md`, `infra/USAGE.md` for Terraform details and `docs/ARCHITECTURE.md` for the big‑picture design.

## Prerequisites

- Terraform >= 1.5, Azure CLI >= 2.50
- Azure subscription with access to Cognitive Services and Azure AI Foundry
- Auth options:
  - Local/dev: `az login` (backend will inherit your CLI auth)
  - CI: OIDC-enabled Service Principal (no secrets) or Managed Identity

## Quick Start

CLI (dev)

- `cd infra/environments/dev`
- `cp dev.tfvars.example dev.auto.tfvars` then edit values (default region is `eastus`, you can change it)
- Optionally bootstrap remote state: `infra/scripts/bootstrap-state.sh` (see `infra/USAGE.md`)
- `terraform init && terraform apply`

Web UI (local)

- `cd backend && npm install && npm start`
- Open `http://localhost:8080`, fill the form, Plan/Apply
- Note: With private endpoints, Azure OpenAI access works only from within the VNet (VPN/peering/jump host or in‑VNet workloads).

## Defaults and Choices

- Identity: System-assigned Managed Identity for app hosting and AI Foundry; Key Vault uses RBAC.
- Networking: Private endpoints and private DNS enabled by default for Azure OpenAI, Storage (blob), and Key Vault.
- Region: Defaults to `eastus`; user can select another region from UI or tfvars.
- AI scope: Azure AI Foundry (Hub + Project) and Azure OpenAI model deployments (via `azapi`). Hooks are in place to add other providers.

## Repository Layout

- `infra/modules/*`: reusable Terraform modules (core, network, storage, openai, ai_foundry, app)
- `infra/environments/{dev,test,prod}`: thin compositions per environment
- `frontend/`: static UI (form + JS) to collect inputs
- `backend/`: Express API that serves the UI and runs Terraform
- `docs/ARCHITECTURE.md`: architecture overview

## CI

- Root workflow: `.github/workflows/terraform.yml`
- Triggers on changes under `AI_Accelerator/infra/**` and runs plan in `infra/environments/dev`
- Configure `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID` GitHub secrets for OIDC login

## Next Steps

- Add non‑OpenAI providers via Azure AI Foundry Model Catalog (e.g., Mistral, Llama, Cohere)
- Extend private endpoints (queues/tables/files), VNet integration for App Service, access restrictions
- Per‑environment CI with `fmt`, `validate`, plan outputs, and protected applies
