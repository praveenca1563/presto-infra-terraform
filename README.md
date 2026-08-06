# PRESTO Data Platform — Infrastructure as Code

Terraform for the PRESTO Data Platform (DEV, per *Environment Request for PRESTO
Data Platform Target State*): networking, ADLS Gen2, Azure Data Factory, Azure
Databricks, Key Vault, plus the GitHub repository itself and self-hosted GitHub
Actions runners — all module-based, with no hardcoded values. Every environment
value comes from `.tfvars`; every credential comes from an environment variable
or CI secret.

## ⚠️ Before you do anything else

The `DetailsInfra.txt` this was generated from contained a **live Azure Service
Principal client secret in plaintext**. That secret was **not** copied into any
file in this repo. You should still:

1. **Rotate that secret now** in Azure AD (App registrations → `prs-dataeng-infra-sp`
   → Certificates & secrets), since it has already been exposed in a chat/document.
2. Never put real secrets in a `.tfvars` file that gets committed. Use
   `TF_VAR_*` environment variables locally, or your CI's secret store.

## Repo layout

```
.
├── main.tf                  # wires all modules together
├── variables.tf              # every root-level input, no defaults for anything env-specific
├── outputs.tf
├── providers.tf              # azurerm / azuread / github providers, values from variables
├── versions.tf                # provider version pins + remote backend block (config supplied at init)
├── modules/
│   ├── resource-group/
│   ├── networking/            # VNet, subnets, NSGs, route table associations
│   ├── storage-account/       # ADLS Gen2 + containers + folders
│   ├── data-factory/          # ADF + managed identity RBAC on storage
│   ├── databricks/            # workspace with VNet injection
│   ├── key-vault/
│   ├── github-repo/           # creates the repo, branch protection, Actions secrets
│   └── github-runners/        # Azure VMSS self-hosted GitHub Actions runners
├── environments/dev/
│   ├── terraform.tfvars                    # non-secret values (safe to commit)
│   ├── secrets.auto.tfvars.example         # template only — copy locally, never commit the real file
│   └── backend.hcl                          # remote state backend config
└── .github/workflows/
    ├── terraform.yml              # PR plan + main-branch apply, runs on the self-hosted runners
    └── terraform-bootstrap.yml    # one-time first apply on GitHub-hosted runners (see below)
```

## Prerequisites

- Terraform >= 1.6
- An Azure Storage account + container for remote state (fill into `backend.hcl`)
- A GitHub PAT or GitHub App token with repo-admin scope, to let the `github`
  provider create the repository/secrets/branch protection
- An SSH key pair for the runner VMs

## Secrets & credentials

None of these belong in a committed `.tfvars` file. Export them as `TF_VAR_*`
env vars locally, or set them as GitHub Environment/Actions secrets for CI:

| Variable | Purpose |
|---|---|
| `TF_VAR_azure_subscription_id` | Target subscription |
| `TF_VAR_azure_tenant_id` | AAD tenant |
| `TF_VAR_azure_client_id` | SP client ID (`prs-dataeng-infra-sp`) |
| `TF_VAR_azure_client_secret` | SP secret — **rotate the one that was in DetailsInfra.txt** |
| `TF_VAR_github_owner` | GitHub org/user |
| `TF_VAR_github_token` | GitHub token used to create the repo itself |
| `TF_VAR_runner_ssh_public_key` | SSH key for runner VMs |
| `TF_VAR_runner_registration_token` | GitHub Actions runner registration token (see caveat below) |

## First-time setup

```bash
# 1. Create remote state storage account/container manually (or via a separate
#    small bootstrap Terraform config — chicken/egg problem for the backend itself).

# 2. Fill in environments/dev/backend.hcl with your state storage account name.

# 3. Export credentials
export TF_VAR_azure_subscription_id="..."
export TF_VAR_azure_tenant_id="..."
export TF_VAR_azure_client_id="..."
export TF_VAR_azure_client_secret="..."
export TF_VAR_github_owner="..."
export TF_VAR_github_token="..."
export TF_VAR_runner_ssh_public_key="$(cat ~/.ssh/id_ed25519.pub)"
export TF_VAR_runner_registration_token="..."   # see note below

# 4. Init, plan, apply
terraform init -backend-config=environments/dev/backend.hcl
terraform plan  -var-file=environments/dev/terraform.tfvars
terraform apply -var-file=environments/dev/terraform.tfvars
```

This single apply creates the GitHub repository (via the `github` provider),
pushes secrets to it, and stands up the self-hosted runner VMSS — so the very
first apply must run somewhere the runners don't need to exist yet (your
laptop, or the `terraform-bootstrap.yml` workflow on `ubuntu-latest`). After
that, `terraform.yml` runs plan/apply on the self-hosted runners it created.

## Runner registration token caveat

GitHub's runner registration tokens are short-lived (~1 hour). The value you
pass in `runner_registration_token` is baked into the VMSS's cloud-init at
creation time, so it's only good for the *initial* scale-up. For ongoing
operation you have two practical options:

1. **Re-provision on scale events**: regenerate the token
   (`gh api -X POST /repos/{owner}/{repo}/actions/runners/registration-token`)
   and re-run `terraform apply` whenever the VMSS needs to scale from zero or
   replace instances.
2. **Migrate to ephemeral/JIT runners**: for a more production-grade setup,
   consider GitHub's Actions Runner Controller (Kubernetes-based) or a small
   Azure Function that mints fresh JIT registration tokens on each VM boot via
   the custom_data script instead of a static token. This repo's `github-runners`
   module is intentionally simple (VMSS-based) as a starting point.

## Adding a new environment

Copy `environments/dev` to `environments/<name>`, adjust `terraform.tfvars`
and `backend.hcl` (different `key`), and run the same `init`/`plan`/`apply`
sequence with `-var-file=environments/<name>/terraform.tfvars`.

## Notes on this DEV configuration

- `create_route_table = false`: the route table `prs-dataeng-cc-core-udr` is
  treated as pre-existing (owned by the network team) and looked up by name.
  Flip to `true` if you want Terraform to own it instead.
- Storage/network defaults favor private networking (`public_network_access_enabled
  = false` on Storage and Key Vault) per the environment request doc's networking
  principles; ADF's public network access defaults `true` until its private
  endpoint is active, matching the doc's stated sequencing.
- AAD group object IDs (`AZ-DEV-PRESTO-CON`, `AZ-DEV-BI-REA`, `AZ-METASTORE-ADM-GRP`)
  aren't in the provided source files, so the `*_object_ids` variables default
  to empty lists. Fill them in once those groups are created and you have their
  object IDs.
