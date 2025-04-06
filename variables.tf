variable "global_settings" {
  description = "Global settings object"
  type        = any
  default = {
    default_region = "region1"
    regions = {
      region1 = "eastus2"
      region2 = "centralus"
    }
  }
}

variable "landingzone" {
  description = "Landing zone object"
  type        = any
  default = {
    backend_type        = "azurerm"
    global_settings_key = "launchpad"
    level               = "level0"
    key                 = "examples"
  }
}

variable "var_folder_path" {
  description = "The path to the folder containing the variables files"
  type        = string
  default     = ""
}

# variable "cloud" {
#   default = {}
# }
# variable "acrLoginServerEndpoint" {
#   default = ".azurecr.io"
# }
# variable "attestationEndpoint" {
#   default = ".attest.azure.net"
# }
# variable "azureDatalakeAnalyticsCatalogAndJobEndpoint" {
#   default = "azuredatalakeanalytics.net"
# }
# variable "azureDatalakeStoreFileSystemEndpoint" {
#   default = "azuredatalakestore.net"
# }
# variable "keyvaultDns" {
#   default = ".vault.azure.net"
# }
# variable "mhsmDns" {
#   default = ".managedhsm.azure.net"
# }
# variable "mysqlServerEndpoint" {
#   default = ".mysql.database.azure.com"
# }
# variable "postgresqlServerEndpoint" {
#   default = ".postgres.database.azure.com"
# }
# variable "sqlServerHostname" {
#   default = ".database.windows.net"
# }
# variable "storageEndpoint" {
#   default = "core.windows.net"
# }
# variable "storageSyncEndpoint" {
#   default = "afs.azure.net"
# }
# variable "synapseAnalyticsEndpoint" {
#   default = ".dev.azuresynapse.net"
# }
# variable "activeDirectory" {
#   default = "https://login.microsoftonline.com"
# }
# variable "activeDirectoryDataLakeResourceId" {
#   default = "https://datalake.azure.net/"
# }
# variable "activeDirectoryGraphResourceId" {
#   default = "https://graph.windows.net/"
# }
# variable "activeDirectoryResourceId" {
#   default = "https://management.core.windows.net/"
# }
# variable "appInsightsResourceId" {
#   default = "https://api.applicationinsights.io"
# }
# variable "appInsightsTelemetryChannelResourceId" {
#   default = "https://dc.applicationinsights.azure.com/v2/track"
# }
# variable "attestationResourceId" {
#   default = "https://attest.azure.net"
# }
# variable "azmirrorStorageAccountResourceId" {
#   default = "null"
# }
# variable "batchResourceId" {
#   default = "https://batch.core.windows.net/"
# }
# variable "gallery" {
#   default = "https://gallery.azure.com/"
# }
# variable "logAnalyticsResourceId" {
#   default = "https://api.loganalytics.io"
# }
# variable "management" {
#   default = "https://management.core.windows.net/"
# }
# variable "mediaResourceId" {
#   default = "https://rest.media.azure.net"
# }
# variable "microsoftGraphResourceId" {
#   default = "https://graph.microsoft.com/"
# }
# variable "ossrdbmsResourceId" {
#   default = "https://ossrdbms-aad.database.windows.net"
# }
# variable "portal" {
#   default = "https://portal.azure.com"
# }
# variable "resourceManager" {
#   default = "https://management.azure.com/"
# }
# variable "sqlManagement" {
#   default = "https://management.core.windows.net:8443/"
# }
# variable "synapseAnalyticsResourceId" {
#   default = "https://dev.azuresynapse.net"
# }
# variable "vmImageAliasDoc" {
#   default = "https://raw.githubusercontent.com/Azure/azure-rest-api-specs/master/arm-compute/quickstart-templates/aliases.json"
# }
variable "environment" {
  type    = string
  default = "sandpit"
}
variable "rover_version" {
  type    = string
  default = null
}
variable "logged_user_objectId" {
  type    = string
  default = null
}
variable "logged_aad_app_objectId" {
  type    = string
  default = null
}
variable "tags" {
  type    = map(any)
  default = null
}
variable "subscription_billing_role_assignments" {
  type    = map(any)
  default = {}
}
variable "app_service_environments" {
  type    = map(any)
  default = {}
}
variable "app_service_environments_v3" {
  type    = map(any)
  default = {}
}
variable "app_service_plans" {
  type    = map(any)
  default = {}
}
variable "app_services" {
  type    = map(any)
  default = {}
}
variable "consumption_budgets" {
  type    = map(any)
  default = {}
}
variable "diagnostics_definition" {
  type    = map(any)
  default = {}
}
variable "resource_groups" {
  type    = map(any)
  default = {}
}

variable "network_managers" {
  type    = any
  default = {}
}

variable "network_manager_admin_rules" {
  type    = any
  default = {}
}

variable "network_manager_admin_rule_collections" {
  type    = any
  default = {}
}

variable "network_manager_connectivity_configurations" {
  type    = any
  default = {}
}

variable "network_manager_deployments" {
  type    = any
  default = {}
}

variable "network_manager_network_groups" {
  type    = any
  default = {}
}

variable "network_manager_management_group_connections" {
  type    = any
  default = {}
}

variable "network_manager_security_admin_configurations" {
  type    = any
  default = {}
}

variable "network_manager_scope_connections" {
  type    = any
  default = {}
}

variable "network_manager_static_members" {
  type    = any
  default = {}
}

variable "network_manager_subscription_connections" {
  type    = any
  default = {}
}

variable "network_security_group_definition" {
  type    = any
  default = {}
}
variable "network_security_perimeters" {
  type    = any
  default = {}
}

variable "network_security_security_rules" {
  type    = any
  default = {}
}
variable "route_tables" {
  type    = any
  default = {}
}
variable "azurerm_routes" {
  type    = any
  default = {}
}
variable "vnets" {
  type    = any
  default = {}
}
variable "virtual_subnets" {
  type    = any
  default = {}
}
variable "azurerm_redis_caches" {
  type    = any
  default = {}
}
variable "mssql_servers" {
  type    = any
  default = {}
}
variable "mssql_managed_instances" {
  type    = any
  default = {}
}
variable "mssql_managed_instances_secondary" {
  type    = any
  default = {}
}
variable "mssql_databases" {
  type    = any
  default = {}
}
variable "mssql_managed_databases" {
  type    = any
  default = {}
}
variable "mssql_managed_databases_restore" {
  type    = any
  default = {}
}
variable "mssql_managed_databases_backup_ltr" {
  type    = any
  default = {}
}
variable "mssql_elastic_pools" {
  type    = any
  default = {}
}
variable "mssql_failover_groups" {
  type    = any
  default = {}
}
variable "mssql_mi_failover_groups" {
  type    = any
  default = {}
}
variable "mssql_mi_administrators" {
  type    = any
  default = {}
}
variable "mssql_mi_tdes" {
  type    = any
  default = {}
}
variable "mssql_mi_secondary_tdes" {
  type    = any
  default = {}
}
variable "storage_accounts" {
  type    = any
  default = {}
}
variable "storage_account_file_shares" {
  type    = any
  default = {}
}
variable "maps_accounts" {
  type    = any
  default = {}
}
variable "azuread_credential_policies" {
  type    = any
  default = {}
}
variable "azuread_applications" {
  type    = any
  default = {}
}
variable "azuread_credentials" {
  type    = any
  default = {}
}
variable "azuread_groups_membership" {
  type    = any
  default = {}
}
variable "azuread_service_principals" {
  type    = any
  default = {}
}
variable "azuread_service_principal_passwords" {
  type    = any
  default = {}
}
variable "azuread_groups" {
  type    = any
  default = {}
}
variable "azuread_roles" {
  type    = any
  default = {}
}
variable "azuread_administrative_units" {
  type    = any
  default = {}
}
variable "azuread_administrative_unit_members" {
  type    = any
  default = {}
}
variable "keyvaults" {
  type    = any
  default = {}
}
variable "keyvault_access_policies" {
  type    = any
  default = {}
}
variable "keyvault_certificate_issuers" {
  type    = any
  default = {}
}
variable "keyvault_keys" {
  type    = any
  default = {}
}
variable "keyvault_certificate_requests" {
  type    = any
  default = {}
}
variable "keyvault_certificates" {
  type    = any
  default = {}
}
variable "virtual_machines" {
  type    = any
  default = {}
}
variable "virtual_machine_scale_sets" {
  type    = any
  default = {}
}
variable "ddos_services" {
  type    = any
  default = {}
}
variable "bastion_hosts" {
  type    = any
  default = {}
}
variable "public_ip_addresses" {
  type    = any
  default = {}
}
variable "diagnostic_storage_accounts" {
  type    = any
  default = {}
}
variable "diagnostic_event_hub_namespaces" {
  type    = any
  default = {}
}
variable "diagnostic_log_analytics" {
  type    = any
  default = {}
}
variable "managed_identities" {
  type    = any
  default = {}
}
variable "private_dns" {
  type    = any
  default = {}
}
variable "synapse_workspaces" {
  type    = any
  default = {}
}
variable "azurerm_application_insights" {
  type    = any
  default = {}
}
variable "azurerm_application_insights_web_test" {
  type    = any
  default = {}
}
variable "azurerm_application_insights_standard_web_test" {
  type    = any
  default = {}
}
variable "role_mapping" {
  type    = any
  default = {}
}
variable "aks_clusters" {
  type    = any
  default = {}
}
variable "azure_container_registries" {
  type    = any
  default = {}
}
variable "batch_accounts" {
  type    = any
  default = {}
}
variable "batch_applications" {
  type    = any
  default = {}
}
variable "batch_certificates" {
  type    = any
  default = {}
}
variable "batch_jobs" {
  type    = any
  default = {}
}
variable "batch_pools" {
  type    = any
  default = {}
}
variable "databricks_workspaces" {
  type    = any
  default = {}
}
variable "databricks_access_connectors" {
  type    = any
  default = {}
}
variable "machine_learning_workspaces" {
  type    = any
  default = {}
}
variable "monitor_action_groups" {
  type    = any
  default = {}
}
variable "monitor_autoscale_settings" {
  type    = any
  default = {}
}
variable "monitoring" {
  type    = any
  default = {}
}
variable "virtual_hubs" {
  type    = any
  default = {}
}
variable "virtual_wans" {
  type    = any
  default = {}
}
variable "event_hub_namespaces" {
  type    = any
  default = {}
}
variable "application_gateways" {
  type    = any
  default = {}
}
variable "application_gateway_platforms" {
  type    = any
  default = {}
}
variable "application_gateway_applications" {
  type    = any
  default = {}
}
variable "application_gateway_applications_v1" {
  type    = any
  default = {}
}
variable "application_gateway_waf_policies" {
  type    = any
  default = {}
}
variable "postgresql_flexible_servers" {
  type    = any
  default = {}
}
variable "postgresql_servers" {
  type    = any
  default = {}
}
variable "log_analytics" {
  type    = any
  default = {}
}
variable "logic_app_workflow" {
  type    = any
  default = {}
}
variable "logic_app_standard" {
  type    = any
  default = {}
}
variable "logic_app_integration_account" {
  type    = any
  default = {}
}
variable "recovery_vaults" {
  type    = any
  default = {}
}
variable "availability_sets" {
  type    = any
  default = {}
}
variable "proximity_placement_groups" {
  type    = any
  default = {}
}
variable "network_watchers" {
  type    = any
  default = {}
}
variable "virtual_network_gateways" {
  type    = any
  default = {}
}
variable "virtual_network_gateway_connections" {
  type    = any
  default = {}
}
variable "express_route_circuits" {
  type    = any
  default = {}
}
variable "express_route_circuit_authorizations" {
  type    = any
  default = {}
}

variable "shared_image_galleries" {
  type    = any
  default = {}
}

variable "image_definitions" {
  type    = any
  default = {}
}

variable "diagnostics_destinations" {
  type    = any
  default = {}
}
variable "vnet_peerings" {
  type    = any
  default = {}
}
variable "vnet_peerings_v1" {
  type    = any
  default = {}
}

variable "packer_service_principal" {
  type    = any
  default = {}
}

variable "packer_build" {
  type    = any
  default = {}
}

variable "azuread_api_permissions" {
  type    = any
  default = {}
}

variable "keyvault_access_policies_azuread_apps" {
  type    = any
  default = {}
}

variable "cosmos_dbs" {
  type    = any
  default = {}
}
variable "dynamic_keyvault_secrets" {
  type    = any
  default = {}
}
variable "dynamic_keyvault_certificates" {
  type    = any
  default = {}
}
variable "front_doors" {
  type    = any
  default = {}
}
variable "front_door_waf_policies" {
  type    = any
  default = {}
}
variable "dns_zones" {
  type    = any
  default = {}
}
variable "dns_zone_records" {
  type    = any
  default = {}
}

variable "private_endpoints" {
  type    = any
  default = {}
}

variable "event_hubs" {
  type    = any
  default = {}
}
variable "automations" {
  type    = any
  default = {}
}
variable "automation_schedules" {
  type    = any
  default = {}
}
variable "automation_runbooks" {
  type    = any
  default = {}
}
variable "automation_log_analytics_links" {
  type    = any
  default = {}
}

variable "local_network_gateways" {
  type    = any
  default = {}
}

variable "domain_name_registrations" {
  type    = any
  default = {}
}

variable "azuread_apps" {
  type    = map(any)
  default = {}
}
variable "azuread_users" {
  type    = map(any)
  default = {}
}
variable "custom_role_definitions" {
  type    = any
  default = {}
}
variable "azurerm_firewalls" {
  type    = any
  default = {}
}
variable "azurerm_firewall_network_rule_collection_definition" {
  type    = any
  default = {}
}
variable "azurerm_firewall_application_rule_collection_definition" {
  type    = any
  default = {}
}
variable "azurerm_firewall_nat_rule_collection_definition" {
  type    = any
  default = {}
}
variable "event_hub_auth_rules" {
  type    = any
  default = {}
}

variable "netapp_accounts" {
  type    = any
  default = {}
}

variable "load_balancers" {
  type    = any
  default = {}
}

variable "ip_groups" {
  type    = any
  default = {}
}
variable "container_app_environments" {
  type    = any
  default = {}
}
variable "container_app_environment_certificates" {
  type    = any
  default = {}
}
variable "container_app_dapr_components" {
  type    = any
  default = {}
}
variable "container_apps" {
  type    = any
  default = {}
}
variable "container_app_environment_storages" {
  type    = any
  default = {}
}
variable "container_groups" {
  type    = any
  default = {}
}
variable "event_hub_namespace_auth_rules" {
  type    = any
  default = {}
}
variable "event_hub_consumer_groups" {
  type    = any
  default = {}
}
variable "application_security_groups" {
  type    = any
  default = {}
}

variable "azurerm_firewall_policies" {
  type    = any
  default = {}
}

variable "azurerm_firewall_policy_rule_collection_groups" {
  type    = any
  default = {}
}
variable "disk_encryption_sets" {
  type    = any
  default = {}
}
variable "vhub_peerings" {
  type        = any
  default     = {}
  description = "Use virtual_hub_connections instead of vhub_peerings. It will be removed in version 6.0"
}
variable "virtual_hub_connections" {
  type    = any
  default = {}
}
variable "virtual_hub_route_table_routes" {
  type    = any
  default = {}
}
variable "virtual_hub_route_tables" {
  type    = any
  default = {}
}
variable "virtual_hub_er_gateway_connections" {
  type    = any
  default = {}
}
variable "wvd_application_groups" {
  type    = any
  default = {}
}
variable "wvd_workspaces" {
  type    = any
  default = {}
}
variable "wvd_host_pools" {
  type    = any
  default = {}
}
variable "wvd_applications" {
  type    = any
  default = {}
}
variable "lighthouse_definitions" {
  type    = any
  default = {}
}
variable "linux_function_apps" {
  type    = any
  default = {}
}
variable "dedicated_host_groups" {
  type    = any
  default = {}
}
variable "dedicated_hosts" {
  type    = any
  default = {}
}
variable "vpn_sites" {
  type    = any
  default = {}
}
variable "vpn_gateway_connections" {
  type    = any
  default = {}
}
variable "vpn_gateway_nat_rules" {
  type    = any
  default = {}
}
variable "servicebus_namespaces" {
  type    = any
  default = {}
}
variable "servicebus_topics" {
  type    = any
  default = {}
}
variable "servicebus_queues" {
  type    = any
  default = {}
}
variable "storage_account_queues" {
  type    = any
  default = {}
}
variable "storage_account_blobs" {
  type    = any
  default = {}
}
variable "storage_containers" {
  type    = any
  default = {}
}
variable "vmware_private_clouds" {
  type    = any
  default = {}
}
variable "vmware_clusters" {
  type    = any
  default = {}
}
variable "vmware_express_route_authorizations" {
  type    = any
  default = {}
}
variable "nat_gateways" {
  type    = any
  default = {}
}
variable "cognitive_services_account" {
  type    = any
  default = {}
}
variable "cognitive_account_customer_managed_key" {
  type    = any
  default = {}
}
variable "cognitive_deployment" {
  type    = any
  default = {}
}

variable "database_migration_services" {
  type    = any
  default = {}
}
variable "database_migration_projects" {
  type    = any
  default = {}
}
variable "data_factory" {
  type    = any
  default = {}
}
variable "data_factory_pipeline" {
  type    = any
  default = {}
}
variable "data_factory_trigger_schedule" {
  type    = any
  default = {}
}
variable "data_factory_dataset_azure_blob" {
  type    = any
  default = {}
}
variable "data_factory_dataset_cosmosdb_sqlapi" {
  type    = any
  default = {}
}
variable "data_factory_dataset_delimited_text" {
  type    = any
  default = {}
}
variable "data_factory_dataset_http" {
  type    = any
  default = {}
}
variable "data_factory_dataset_json" {
  type    = any
  default = {}
}
variable "data_factory_dataset_mysql" {
  type    = any
  default = {}
}
variable "data_factory_dataset_postgresql" {
  type    = any
  default = {}
}
variable "data_factory_dataset_sql_server_table" {
  type    = any
  default = {}
}
variable "data_factory_linked_service_azure_blob_storage" {
  type    = any
  default = {}
}
variable "data_factory_linked_service_cosmosdb" {
  type    = any
  default = {}
}
variable "data_factory_linked_service_web" {
  type    = any
  default = {}
}
variable "data_factory_linked_service_mysql" {
  type    = any
  default = {}
}
variable "data_factory_linked_service_postgresql" {
  type    = any
  default = {}
}
variable "data_factory_linked_service_sql_server" {
  type    = any
  default = {}
}
variable "data_factory_linked_service_azure_databricks" {
  type    = any
  default = {}
}
variable "integration_service_environment" {
  type    = any
  default = {}
}
variable "logic_app_action_http" {
  type    = any
  default = {}
}
variable "logic_app_action_custom" {
  type    = any
  default = {}
}
variable "logic_app_trigger_http_request" {
  type    = any
  default = {}
}
variable "logic_app_trigger_recurrence" {
  type    = any
  default = {}
}
variable "logic_app_trigger_custom" {
  type    = any
  default = {}
}
variable "kusto_clusters" {
  type    = any
  default = {}
}
variable "kusto_databases" {
  type    = any
  default = {}
}
variable "kusto_attached_database_configurations" {
  type    = any
  default = {}
}
variable "kusto_cluster_customer_managed_keys" {
  type    = any
  default = {}
}
variable "kusto_cluster_principal_assignments" {
  type    = any
  default = {}
}
variable "kusto_database_principal_assignments" {
  type    = any
  default = {}
}
variable "kusto_eventgrid_data_connections" {
  type    = any
  default = {}
}
variable "kusto_eventhub_data_connections" {
  type    = any
  default = {}
}
variable "kusto_iothub_data_connections" {
  type    = any
  default = {}
}
variable "private_dns_vnet_links" {
  type    = any
  default = {}
}
variable "communication_services" {
  type    = any
  default = {}
}
variable "machine_learning_compute_instance" {
  type    = any
  default = {}
}
variable "data_factory_integration_runtime_self_hosted" {
  type    = any
  default = {}
}
variable "data_factory_integration_runtime_azure_ssis" {
  type    = any
  default = {}
}
variable "frontdoor_rules_engine" {
  type    = any
  default = {}
}
variable "frontdoor_custom_https_configuration" {
  type    = any
  default = {}
}
variable "cdn_endpoint" {
  type    = any
  default = {}
}
variable "cdn_profile" {
  type    = any
  default = {}
}
variable "function_apps" {
  type    = any
  default = {}
}
variable "active_directory_domain_service" {
  type    = any
  default = {}
}
variable "active_directory_domain_service_replica_set" {
  type    = any
  default = {}
}
variable "mysql_flexible_server" {
  type    = any
  default = {}
}

variable "signalr_services" {
  type    = any
  default = {}
}
variable "api_management" {
  type    = any
  default = {}
}
variable "api_management_api" {
  type    = any
  default = {}
}
variable "api_management_api_diagnostic" {
  type    = any
  default = {}
}
variable "api_management_logger" {
  type    = any
  default = {}
}
variable "api_management_api_operation" {
  type    = any
  default = {}
}
variable "api_management_backend" {
  type    = any
  default = {}
}
variable "api_management_api_policy" {
  type    = any
  default = {}
}
variable "api_management_api_operation_policy" {
  type    = any
  default = {}
}
variable "api_management_api_operation_tag" {
  type    = any
  default = {}
}
variable "api_management_user" {
  type    = any
  default = {}
}
variable "api_management_custom_domain" {
  type    = any
  default = {}
}
variable "api_management_diagnostic" {
  type    = any
  default = {}
}
variable "api_management_certificate" {
  type    = any
  default = {}
}
variable "api_management_gateway" {
  type    = any
  default = {}
}
variable "api_management_gateway_api" {
  type    = any
  default = {}
}
variable "api_management_group" {
  type    = any
  default = {}
}
variable "api_management_subscription" {
  type    = any
  default = {}
}
variable "api_management_product" {
  type    = any
  default = {}
}
variable "lb" {
  type    = any
  default = {}
}
variable "lb_backend_address_pool" {
  type    = any
  default = {}
}
variable "lb_backend_address_pool_address" {
  type    = any
  default = {}
}
variable "lb_nat_pool" {
  type    = any
  default = {}
}
variable "lb_nat_rule" {
  type    = any
  default = {}
}
variable "lb_outbound_rule" {
  type    = any
  default = {}
}
variable "lb_probe" {
  type    = any
  default = {}
}
variable "lb_rule" {
  type    = any
  default = {}
}
variable "network_interface_backend_address_pool_association" {
  type    = any
  default = {}
}
variable "digital_twins_instances" {
  type        = any
  description = "Digital Twins Instances"
  default     = {}
}

variable "digital_twins_endpoint_eventhubs" {
  type        = any
  description = "Digital Twins Endpoints Eventhubs"
  default     = {}
}

variable "digital_twins_endpoint_eventgrids" {
  type        = any
  description = "Digital Twins Endpoints Eventgrid"
  default     = {}
}

variable "digital_twins_endpoint_servicebuses" {
  type        = any
  description = "Digital Twins Endpoints Service Bus"
  default     = {}
}

variable "monitor_metric_alert" {
  type    = any
  default = {}
}
variable "monitor_activity_log_alert" {
  type    = any
  default = {}
}
variable "log_analytics_storage_insights" {
  type    = any
  default = {}
}
variable "eventgrid_domain" {
  type    = any
  default = {}
}
variable "eventgrid_topic" {
  type    = any
  default = {}
}
variable "eventgrid_event_subscription" {
  type    = any
  default = {}
}
variable "eventgrid_domain_topic" {
  type    = any
  default = {}
}
variable "relay_hybrid_connection" {
  type    = any
  default = {}
}
variable "relay_namespace" {
  type    = any
  default = {}
}
variable "purview_accounts" {
  type    = any
  default = {}
}
variable "app_config" {
  type    = any
  default = {}
}
variable "cosmosdb_sql_databases" {
  type    = any
  default = {}
}
variable "sentinel" {
  type    = any
  default = {}
}
variable "sentinel_automation_rules" {
  type    = any
  default = {}
}
variable "sentinel_watchlists" {
  type    = any
  default = {}
}
variable "sentinel_watchlist_items" {
  type    = any
  default = {}
}
variable "sentinel_ar_fusions" {
  type    = any
  default = {}
}
variable "sentinel_ar_ml_behavior_analytics" {
  type    = any
  default = {}
}
variable "sentinel_ar_ms_security_incidents" {
  type    = any
  default = {}
}
variable "sentinel_ar_scheduled" {
  type    = any
  default = {}
}
variable "sentinel_dc_aad" {
  type    = any
  default = {}
}
variable "sentinel_dc_app_security" {
  type    = any
  default = {}
}
variable "sentinel_dc_aws" {
  type    = any
  default = {}
}
variable "sentinel_dc_azure_threat_protection" {
  type    = any
  default = {}
}
variable "sentinel_dc_ms_threat_protection" {
  type    = any
  default = {}
}
variable "sentinel_dc_office_365" {
  type    = any
  default = {}
}
variable "sentinel_dc_security_center" {
  type    = any
  default = {}
}
variable "sentinel_dc_threat_intelligence" {
  type    = any
  default = {}
}
variable "public_ip_prefixes" {
  type    = any
  default = {}
}
variable "runbooks" {
  type    = any
  default = {}
}
variable "backup_vaults" {
  type    = any
  default = {}
}
variable "backup_vault_policies" {
  type    = any
  default = {}
}
variable "backup_vault_instances" {
  type    = any
  default = {}
}
variable "traffic_manager_azure_endpoint" {
  type    = any
  default = {}
}
variable "traffic_manager_external_endpoint" {
  type    = any
  default = {}
}
variable "traffic_manager_nested_endpoint" {
  type    = any
  default = {}
}
variable "traffic_manager_profile" {
  type    = any
  default = {}
}
variable "resource_provider_registration" {
  type    = any
  default = {}
}
variable "static_sites" {
  type    = any
  default = {}
}
variable "aro_clusters" {
  type    = any
  default = {}
}
variable "web_pubsubs" {
  type    = any
  default = {}
}
variable "web_pubsub_hubs" {
  type    = any
  default = {}
}
variable "aadb2c_directory" {
  type    = any
  default = {}
}
variable "powerbi_embedded" {
  type    = any
  default = {}
}
variable "preview_features" {
  type    = any
  default = {}
}
variable "private_dns_resolvers" {
  type    = any
  default = {}
}
variable "private_dns_resolver_inbound_endpoints" {
  type    = any
  default = {}
}
variable "private_dns_resolver_outbound_endpoints" {
  type    = any
  default = {}
}
variable "private_dns_resolver_dns_forwarding_rulesets" {
  type    = any
  default = {}
}

variable "private_dns_resolver_forwarding_rules" {
  type    = any
  default = {}
}

variable "private_dns_resolver_virtual_network_links" {
  type    = any
  default = {}
}

variable "iot_security_solution" {
  type    = any
  default = {}
}
variable "iot_security_device_group" {
  type    = any
  default = {}
}
variable "iot_central_application" {
  type    = any
  default = {}
}
variable "iot_hub" {
  type    = any
  default = {}
}
variable "iot_hub_dps" {
  type    = any
  default = {}
}
variable "iot_hub_shared_access_policy" {
  type    = any
  default = {}
}
variable "iot_dps_certificate" {
  type    = any
  default = {}
}
variable "iot_dps_shared_access_policy" {
  type    = any
  default = {}
}
variable "iot_hub_consumer_groups" {
  type    = any
  default = {}
}
variable "iot_hub_certificate" {
  type    = any
  default = {}
}
variable "cosmosdb_role_mapping" {
  type    = any
  default = {}
}
variable "cosmosdb_role_definitions" {
  type    = any
  default = {}
}
variable "data_sources" {
  type    = any
  default = {}
}
variable "maintenance_configuration" {
  type    = any
  default = {}
}
variable "maintenance_assignment_virtual_machine" {
  type    = any
  default = {}
}
variable "search_services" {
  type    = any
  default = {}
}
variable "load_test" {
  type    = any
  default = {}
}
