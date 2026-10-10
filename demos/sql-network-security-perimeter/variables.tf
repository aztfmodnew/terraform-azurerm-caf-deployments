variable "subscription_id" {
  type        = string
  description = "Authorized disposable lab subscription."
}

variable "location" {
  type    = string
  default = "westeurope"
}

variable "lab_name" {
  type    = string
  default = "nsp-tour-sql"
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,30}$", var.lab_name))
    error_message = "Use 3-31 lowercase letters, digits or hyphens."
  }
}

variable "unique_suffix" {
  type        = string
  description = "Globally unique suffix for SQL and Storage names."
  validation {
    condition     = can(regex("^[a-z0-9]{6,16}$", var.unique_suffix))
    error_message = "Use 6-16 lowercase letters or digits."
  }
}

variable "operator_ipv4" {
  type        = string
  description = "Fixed public IPv4 of the demo client; never 0.0.0.0."
  validation {
    condition = can(cidrnetmask("${var.operator_ipv4}/32")) && !contains(
      ["0.0.0.0", "255.255.255.255", "127.0.0.1"], var.operator_ipv4
    )
    error_message = "Provide the client's actual public IPv4, without a CIDR suffix."
  }
}

variable "sql_admin_name" {
  type        = string
  description = "Display name of the lab-only Entra administrator user/group."
}

variable "sql_admin_object_id" {
  type        = string
  description = "Entra object ID, not application/client ID."
}

variable "access_mode" {
  type    = string
  default = "Transition"
  validation {
    condition     = contains(["Transition", "Enforced"], var.access_mode)
    error_message = "Use Transition (formerly Learning) or Enforced."
  }
}

variable "allow_blob_outbound" {
  type    = bool
  default = false
}
