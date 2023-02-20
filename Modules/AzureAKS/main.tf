terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0.0"
    }
  }
  experiments = [module_variable_optional_attrs]
}

data "azurerm_subscription" "current" {
}

data "azurerm_client_config" "current" {
}

data "azurerm_key_vault" "existing" {
  name                = "pharmatfstate-kv"
  resource_group_name = "terraform-mgmt"
}

data "azurerm_key_vault_secret" "secret" {
  name         = "aks-key"
  key_vault_id = data.azurerm_key_vault.existing.id
}

locals {
  # Common tags to be assigned to all resources
  common_tags = {
    "CreatedBy"   = var.owner
    "Environment" = var.environment
  }
  default_agent_profile = {
    name                  = var.default_agent_profile_name
    count                 = var.default_agent_profile_count
    vm_size               = var.default_agent_profile_vmsize
    os_type               = var.default_agent_profile_ostype
    availability_zones    = var.default_agent_profile_availability_zones
    enable_auto_scaling   = var.default_agent_profile_enable_auto_scaling
    min_count             = var.default_agent_profile_min_count
    max_count             = var.default_agent_profile_max_count
    type                  = var.default_agent_profile_vmtype
    node_taints           = var.default_agent_profile_node_taints
    vnet_subnet_id        = var.default_agent_profile_nodes_subnet_id
    max_pods              = var.default_agent_profile_max_pods
    os_disk_type          = var.default_agent_profile_osdisk_type
    os_disk_size_gb       = var.default_agent_profile_osdisk_size
    enable_node_public_ip = var.default_agent_profile_enable_node_public_ip
  }

  # Defaults for Linux profile
  # Generally smaller images so can run more pods and require smaller HD
  default_linux_node_profile = {
    max_pods        = 110
    os_disk_size_gb = 128
  }

  # Defaults for Windows profile
  # Do not want to run same number of pods and some images can be quite large
  default_windows_node_profile = {
    max_pods        = 20
    os_disk_size_gb = 256
  }

  default_node_pool = merge(local.default_agent_profile, var.default_node_pool)

  nodes_pools_with_defaults = [for ap in var.nodes_pools : merge(local.default_agent_profile, ap)]
  nodes_pools               = [for ap in local.nodes_pools_with_defaults : ap.os_type == "Linux" ? merge(local.default_linux_node_profile, ap) : merge(local.default_windows_node_profile, ap)]

}

resource "random_string" "random" {
  length  = 3
  special = false
  upper   = false
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                              = "${var.prefix}-aks-devopsdev"
  location                          = var.location
  resource_group_name               = var.resource_group_name
  dns_prefix                        = var.prefix
  kubernetes_version                = var.kubernetes_version
  sku_tier                          = var.aks_sku_tier
  api_server_authorized_ip_ranges   = var.private_cluster_enabled ? null : var.api_server_authorized_ip_ranges
  node_resource_group               = var.node_resource_group
  enable_pod_security_policy        = var.enable_pod_security_policy
  role_based_access_control_enabled = var.rbac_enabled


  private_cluster_enabled = var.private_cluster_enabled
  private_dns_zone_id     = var.private_cluster_enabled && var.private_dns_zone_type == "Custom" ? var.private_dns_zone_id : var.private_dns_zone_type

  default_node_pool {
    name                = local.default_node_pool.name
    node_count          = local.default_node_pool.count
    vm_size             = local.default_node_pool.vm_size
    zones               = local.default_node_pool.availability_zones
    enable_auto_scaling = local.default_node_pool.enable_auto_scaling
    min_count           = local.default_node_pool.min_count
    max_count           = local.default_node_pool.max_count
    max_pods            = local.default_node_pool.max_pods
    os_disk_type        = local.default_node_pool.os_disk_type
    os_disk_size_gb     = local.default_node_pool.os_disk_size_gb
    type                = local.default_node_pool.type
    vnet_subnet_id      = local.default_node_pool.vnet_subnet_id
    node_taints         = local.default_node_pool.node_taints
  }

  identity {
    type = var.private_cluster_enabled && var.private_dns_zone_type == "Custom" ? "UserAssigned" : "SystemAssigned"
  }

  dynamic "oms_agent" {
    for_each = var.oms_agent == null ? [] : [var.oms_agent]
    iterator = rule

    content {
      log_analytics_workspace_id = rule.value.oms_agent_workspace_id
    }
  }

  azure_policy_enabled = var.addons.policy

  dynamic "linux_profile" {
    for_each = var.linux_profile != null ? [true] : []
    iterator = lp
    content {
      admin_username = var.linux_profile.username

      ssh_key {
        key_data = data.azurerm_key_vault_secret.secret.value
      }
    }
  }

  network_profile {
    network_plugin     = "azure"
    network_policy     = "azure"
    dns_service_ip     = cidrhost(var.service_cidr, 10)
    docker_bridge_cidr = var.docker_bridge_cidr
    service_cidr       = var.service_cidr
    load_balancer_sku  = "standard"
    outbound_type      = var.outbound_type

  }

  dynamic "azure_active_directory_role_based_access_control" {
    for_each = var.azure_active_directory_role_based_access_control == null ? [] : [var.azure_active_directory_role_based_access_control]
    iterator = rule

    content {
      managed                = rule.value.azure_rbac_managed
      azure_rbac_enabled     = rule.value.azure_rbac_enabled
      admin_group_object_ids = rule.value.admin_group_object_ids
    }
  }

  lifecycle {
    ignore_changes        = [default_node_pool]
    create_before_destroy = true
  }

  tags = local.common_tags
}

resource "azurerm_kubernetes_cluster_node_pool" "node_pools" {
  count                 = length(local.nodes_pools)
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  name                  = local.nodes_pools[count.index].name
  vm_size               = local.nodes_pools[count.index].vm_size
  os_type               = local.nodes_pools[count.index].os_type
  os_disk_type          = local.nodes_pools[count.index].os_disk_type
  os_disk_size_gb       = local.nodes_pools[count.index].os_disk_size_gb
  vnet_subnet_id        = local.nodes_pools[count.index].vnet_subnet_id
  enable_auto_scaling   = local.nodes_pools[count.index].enable_auto_scaling
  node_count            = local.nodes_pools[count.index].count
  min_count             = local.nodes_pools[count.index].min_count
  max_count             = local.nodes_pools[count.index].max_count
  max_pods              = local.nodes_pools[count.index].max_pods
  enable_node_public_ip = local.nodes_pools[count.index].enable_node_public_ip
  zones                 = local.nodes_pools[count.index].availability_zones

  lifecycle {
    create_before_destroy = true
  }
}

# Allow user assigned identity to manage AKS items in MC_xxx RG
resource "azurerm_role_assignment" "aks_user_assigned" {
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  scope                = format("/subscriptions/%s/resourceGroups/%s", data.azurerm_subscription.current.subscription_id, azurerm_kubernetes_cluster.aks.node_resource_group)
  role_definition_name = "Contributor"
}

resource "azurerm_role_assignment" "aks_acr_pull_allowed" {
  principal_id         = azurerm_kubernetes_cluster.aks.identity[0].principal_id
  scope                = var.container_registries_id
  role_definition_name = "AcrPull"
}

resource "azurerm_role_assignment" "aks_agents_acr_pull_allowed" {
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  scope                = var.container_registries_id
  role_definition_name = "AcrPull"
}

# Create Conainer Insights Solution
resource "azurerm_log_analytics_solution" "ContainerInsights" {
  count = var.enable_log_workspace ? 1 : 0

  solution_name         = "ContainerInsights"
  location              = var.location
  resource_group_name   = var.resource_group_name
  workspace_resource_id = var.workspace_id
  workspace_name        = var.workspace_name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}
