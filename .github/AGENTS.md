# 🤖 Available Agents - terraform-azurerm-caf-deployments

This document lists AI agents for deployment scenarios and reusable stacks in `terraform-azurerm-caf-deployments`.

## 🚀 Deployment Agents

### **Scenario Deployment Orchestrator**
**Purpose:** Plan/apply/destroy stack scenarios safely using repository tooling.

**When to use:**
- "Deploy a stack under `stacks/`"
- "Run safe destroy for a demo workspace"

### **Stack Refactoring Assistant**
**Purpose:** Refactor stack variables/modules while preserving behavior.

**When to use:**
- "Standardize stack inputs"
- "Extract repeated patterns to modules"

### **Workspace & State Manager**
**Purpose:** Manage workspaces/backends and avoid state collisions.

**When to use:**
- "Fix workspace/backend mismatch"
- "Align var-files with target workspace"

### **Demo Reliability Engineer**
**Purpose:** Keep demos runnable and reproducible.

**When to use:**
- "Fix broken demo deployment"
- "Update scripts under `tools/`"

## ✅ Validation Checklist

- `terraform init/plan` succeeds for touched stack
- Workspace name and backend are explicit
- README/usage examples updated
- Destroy path validated for cleanup

**Last Updated:** March 2026
**Namespace:** aztfmodnew/terraform-azurerm-caf-deployments
