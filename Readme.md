# Deployments with Terraform

## Overview
This repository contains Terraform code to deploy demos  in Azure Cloud using Terraform az.

## Demos (shared repository root)

- [Azure SQL Database outbound access with Network Security Perimeter](demos/sql-network-security-perimeter/README.md):
  sector-specific tfvars loaded by the repository tools into root `module.example`
  (**CAF 5.0.0**), plus SQL scripts for Transition/Enforced/FQDN comparisons.
  Run from the repository root with an explicit workspace, like
  `demos/300-advanced-network-manager`. The earlier autonomous Azure rehearsal is
  historical, not validation of this new root.
  The shared root was also deployed and tested on 2026-10-10: A/C read two
  events, B/D blocked with SQL 40197/25717 after propagation. The final reviewed
  destroy removed 19 Terraform objects; empty state and absent resource group
  were verified. See the demo's `ensayo-raiz-azure.json` for evidence and limits.

See [CAF 5 migration/compatibility notes](tools/CAF5.md) before planning existing
demos. Removed upstream resource types require migration; do not blindly apply.

In general, follow these steps to deploy a stack or demo:

1. Clone the repository
2. Load tools scripts
    - `source ./tools/terraform_with_var_files.sh` for Linux
    - `. .\tools\terraform_with_var_files.ps1` for Windows (dot-source the function)
3. Execute the deployment script

```	bash
az login
export ARM_SUBSCRIPTION_ID=<your-subscription-id>
terraform_with_var_files --dir stacks/Baseline_web_application_with_zone_redundancy/ --action plan --workspace Baseline_web_application_with_zone_redundancy
terraform_with_var_files --dir stacks/Baseline_web_application_with_zone_redundancy/ --action apply --workspace Baseline_web_application_with_zone_redundancy --auto auto

```
4. Destroy the stack when done

```	bash
terraform_with_var_files --dir stacks/Baseline_web_application_with_zone_redundancy/ --action destroy --workspace Baseline_web_application_with_zone_redundancy
```
