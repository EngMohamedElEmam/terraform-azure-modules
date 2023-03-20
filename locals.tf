/* locals {
  Reader_principals  = [data.azuread_user.user5.object_id, data.azuread_user.user4.object_id, data.azuread_user.user3.object_id, data.azuread_user.user2.object_id, data.azuread_user.user1.object_id]
  AcrPull_principals = [data.azuread_user.user5.object_id, data.azuread_user.user4.object_id, data.azuread_user.user3.object_id, data.azuread_user.user2.object_id, data.azuread_user.user1.object_id]
} */

locals {
  roleacr = {
    "Reader"  = [data.azuread_user.emam.object_id]
    "AcrPull" = [data.azuread_user.emam.object_id]
  }
}

locals {
  roleaks = {
    "Azure Kubernetes Service Cluster User Role"  = [data.azuread_user.emam.object_id]
    "Azure Kubernetes Service Cluster Admin Role" = [data.azuread_user.emam.object_id]
    "Azure Kubernetes Service RBAC Cluster Admin" = [data.azuread_user.emam.object_id]
  }
}

