variable "cloud" {
  description = "Azure Public endpoints matching CAF 5 defaults; merge partial sovereign-cloud overrides via caf_overrides.cloud."
  type        = map(string)
  default = {
    acrLoginServerEndpoint                      = ".azurecr.io"
    attestationEndpoint                         = ".attest.azure.net"
    azureDatalakeAnalyticsCatalogAndJobEndpoint = "azuredatalakeanalytics.net"
    azureDatalakeStoreFileSystemEndpoint        = "azuredatalakestore.net"
    keyvaultDns                                 = ".vault.azure.net"
    mhsmDns                                     = ".managedhsm.azure.net"
    mysqlServerEndpoint                         = ".mysql.database.azure.com"
    postgresqlServerEndpoint                    = ".postgres.database.azure.com"
    sqlServerHostname                           = ".database.windows.net"
    storageEndpoint                             = "core.windows.net"
    storageSyncEndpoint                         = "afs.azure.net"
    synapseAnalyticsEndpoint                    = ".dev.azuresynapse.net"
    communicationEndpoint                       = ".communication.azure.com"
    cosmosdbEndpoint                            = ".documents.azure.com"
    cognitiveServicesEndpoint                   = ".cognitiveservices.azure.com"
    containerAppsEndpoint                       = ".azurecontainerapps.io"
    eventgridEndpoint                           = ".eventgrid.azure.net"
    iotCentralEndpoint                          = ".azureiotcentral.com"
    iotHubEndpoint                              = ".azure-devices.net"
    iotDpsEndpoint                              = ".azure-devices-provisioning.net"
    kustoEndpoint                               = ".kusto.windows.net"
    mapsEndpoint                                = "atlas.microsoft.com"
    powerbiEndpoint                             = "api.powerbi.com"
    purviewEndpoint                             = ".purview.azure.com"
    redisCacheHostname                          = ".redis.cache.windows.net"
    searchServiceEndpoint                       = ".search.windows.net"
    servicebusEndpoint                          = ".servicebus.windows.net"
    signalrEndpoint                             = ".service.signalr.net"
    trafficManagerEndpoint                      = ".trafficmanager.net"
    webPubsubEndpoint                           = ".webpubsub.azure.com"
    digitalTwinsEndpoint                        = ".digitaltwins.azure.net"
    activeDirectory                             = "https://login.microsoftonline.com"
    activeDirectoryDataLakeResourceId           = "https://datalake.azure.net/"
    activeDirectoryGraphResourceId              = "https://graph.windows.net/"
    activeDirectoryResourceId                   = "https://management.core.windows.net/"
    appInsightsResourceId                       = "https://api.applicationinsights.io"
    appInsightsTelemetryChannelResourceId       = "https://dc.applicationinsights.azure.com/v2/track"
    attestationResourceId                       = "https://attest.azure.net"
    azmirrorStorageAccountResourceId            = "null"
    batchResourceId                             = "https://batch.core.windows.net/"
    gallery                                     = "https://gallery.azure.com/"
    logAnalyticsResourceId                      = "https://api.loganalytics.io"
    management                                  = "https://management.core.windows.net/"
    mediaResourceId                             = "https://rest.media.azure.net"
    microsoftGraphResourceId                    = "https://graph.microsoft.com/"
    ossrdbmsResourceId                          = "https://ossrdbms-aad.database.windows.net"
    portal                                      = "https://portal.azure.com"
    resourceManager                             = "https://management.azure.com/"
    sqlManagement                               = "https://management.core.windows.net:8443/"
    synapseAnalyticsResourceId                  = "https://dev.azuresynapse.net"
    vmImageAliasDoc                             = "https://raw.githubusercontent.com/Azure/azure-rest-api-specs/master/arm-compute/quickstart-templates/aliases.json"
  }
}

variable "caf_overrides" {
  description = "CAF 5 grouped inputs and new rails not represented by the legacy flat variables. Group keys override legacy entries."
  type        = any
  default     = {}
}

variable "remote_objects" {
  description = "Objects exported by other CAF landing zones."
  type        = any
  default     = {}
}

variable "entra_only_sql_servers" {
  description = "Opt-in Entra-only SQL servers avoiding CAF 5.0.0's unconditional password/Key Vault helper. No SQL identity is created."
  type = map(object({
    name               = string
    resource_group_key = string
    region             = string
    administrator = object({
      login_username = string
      object_id      = string
      tenant_id      = string
    })
    operator_ipv4 = string
  }))
  default = {}

  validation {
    condition     = alltrue([for server in values(var.entra_only_sql_servers) : can(cidrnetmask("${server.operator_ipv4}/32"))])
    error_message = "operator_ipv4 must be a single IPv4 address (not a CIDR); both SQL firewall and NSP use this /32."
  }
}

variable "sql_nsp_demo" {
  description = "Optional SQL NSP demo selectors and A/B/C/D controls; null leaves other demos unchanged."
  type = object({
    sql_server_key      = string
    storage_account_key = string
    nsp_key             = string
    profile_key         = string
    access_mode         = optional(string, "Transition")
    allow_blob_outbound = optional(bool, false)
  })
  default = null

  validation {
    condition     = var.sql_nsp_demo == null ? true : contains(["Transition", "Enforced"], var.sql_nsp_demo.access_mode)
    error_message = "The SQL NSP demo supports Transition or Enforced; CAF's 2023 API translates Transition to Learning."
  }
}
