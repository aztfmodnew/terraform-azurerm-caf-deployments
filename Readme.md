# Deployments with Terraform

## Overview
This repository contains Terraform code to deploy demos  in Azure Cloud using Terraform az.

In general, follow these steps to deploy a stack or demo:

1. Clone the repository
2. Load tools scripts
    - `source ./tools/terraform_with_var_files.sh` for Linux
    - `.\tools\terraform_with_var_files.ps1` for Windows
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


