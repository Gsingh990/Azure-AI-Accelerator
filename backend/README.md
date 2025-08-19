# Backend API

A small Express server that serves the static frontend and exposes `/api/plan` and `/api/apply` endpoints to run Terraform in `infra/environments/<env>`.

## Run locally

- Ensure Terraform and Azure CLI are installed and authenticated
- `cd backend && npm install`
- Copy `.env.example` to `.env` and adjust as needed
- `npm start`

POST payloads

- `/api/plan|apply` with body `{ cfg: {...}, tfvars: "..." }`

Security

- Prefer running this API behind corporate auth and call Terraform using a managed identity or OIDC-bound service principal.
