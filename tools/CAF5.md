# Root wrapper: CAF 5.0.0

The root `module.example` uses `aztfmodnew/caf/azurerm` **exactly 5.0.0**.
Dynamic certificate/secret helpers use the same release. Run Terraform at the
repository root; demo directories contain sector-specific `*.tfvars`, not roots.

## API compatibility

The downloaded release's `variables.*.tf`, `locals.tf` and outputs are the API
used for this upgrade. Existing flat variables are retained, not bulk-deleted.
`objects` still exports the module's non-empty outputs keyed by `landingzone.key`
and remains sensitive. CAF 5 determines the resource output names and schemas;
consumers of CAF 4 state must review them before upgrading.

New CAF rails and grouped settings are exposed through `caf_overrides`:
`analytics`, `bot`, `billing`, `cache`, `cdn`, `palo_alto`, `pim`, `dashboards`,
`monitoring`, `chaos_studio`, `invoice_sections`, `random_strings`, `client_config`,
`subscriptions`, `tfstates`, `enable`, `cloud`, tenant/connectivity IDs, `user_type`,
and `use_msi`. For existing groups, overrides are merged **shallowly** with the
legacy mappings; an overridden resource map replaces that entire map. Examples:

```hcl
caf_overrides = {
  analytics = { fabric_capacities = {} }
  webapp    = { linux_web_apps = {}, windows_function_apps = {} }
  storage   = { storage_account_static_websites = {} }
  networking = { route_servers = {}, network_profiles = {} }
}
```

This also exposes other CAF 5 additions (AI services, managed Redis, PIM, domain
service trusts, migration projects, monitoring, software update configurations,
etc.) without inventing a separate root schema. `remote_objects` remains a direct
input. Use the downloaded release's schemas, not arbitrary keys.

Two renamed legacy inputs are translated:

| Root flat input retained | CAF 5 grouped key |
| --- | --- |
| `mysql_flexible_server` | `database.mysql_flexible_servers` |
| `network_manager_scope_connections` | `networking.network_manager_scope_connection` |

Removed surfaces cannot be made compatible by a wrapper: Batch certificates,
PostgreSQL Single Server, Front Door/CDN Classic, generic `app_services`,
`app_service_plans`, `function_apps` and `security.sentinel`. Configure Sentinel
on the CAF Log Analytics workspace's `sentinel` settings instead. The `objects`
output precondition rejects
non-empty legacy inputs rather than producing an empty/misleading plan. Migrate
to supported Flexible Server, CDN Front Door profiles, `service_plans`,
Linux/Windows Web Apps and Function Apps. Migration can require resource/state
changes; this PR does not apply those changes to existing deployments.

Terraform >= 1.8 is required by CAF 5. AzureRM resolves to ~> 5.8 and AzureAD to
~> 3.9 through the module. AzureRM 5 removed the VM `graceful_shutdown` feature:
the legacy provider variable is retained but that feature is no longer sent.
Naming/provider changes can alter existing plans; there is no guarantee of a
no-op upgrade across every historical demo. Do not blindly apply an upgrade.

## SQL-only opt-in exception

CAF 5 `mssql_servers.tf` resolves a Key Vault unless a password attribute exists;
`modules/databases/mssql_server/server.tf` creates `random_password` and a Key
Vault secret whenever the password is null, **including Entra-only servers**.
Passing null therefore does not avoid it; a fake password is not a solution.

`entra_only_sql_servers` defaults to `{}`. The narrowly scoped root helper creates
only an Entra-only logical server and its single-IP firewall rule, with no
identity/password/Key Vault. It exports ID/name under the `entra_only` remote
object namespace, consumed by CAF's database and NSP modules. Resource groups,
Storage/container, database, logs, NSP/profile/rules/association and diagnostics
remain CAF-managed. SQL-specific optional `sql_nsp_demo` defaults to null.
The demo-only root RBAC assignment grants its operator Storage Blob Data
Contributor at the account scope (also gated by that null default), avoiding
personal principal IDs in the public role-map files.
Its endpoint-only output is non-secret; do not project `objects` or state.

## Wrappers

Dot-source the PowerShell function or source the Bash function from the root.
All sector files are loaded in filename order (a local `zz-local.tfvars` wins).
Arrays preserve filenames/arguments containing spaces and avoid `eval`.
`-TerraformArguments` / `-- ARGS` supports `-input=false`, `-out=...`, `-destroy`
and `-var=...`. Wrapper actions still select/create the **explicit** workspace.
SQL runners require that workspace already selected and never select one.
