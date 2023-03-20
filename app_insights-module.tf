/* ######################
#App Insight Modules #
######################

#Create log analytics workspace for the Application Insghts
module "PharmaInsight-WorkSpace" {
  source                                    = "./AzureLogging/logs"
  resource_group_name                       = module.logs-rg.rg_name_out
  location                                  = "East US"
  log_analytics                             = "pharmainsight-workspace"
  log_analytics_workspace_sku               = "Standalone"
  log_analytics_workspace_retention_in_days = "90"
}

#Create Application Insghts
module "Pharma-Insight" {
  source                              = "./AzureMonitor/AppInsights"
  resource_group_name                 = module.monitoring-rg.rg_name_out
  location                            = "East US"
  app_insight_name                    = "pharma-insight"
  application_type                    = "web"
  daily_data_cap_in_gb                = 50
  log_analytics_workspace_resource_id = module.PharmaInsight-WorkSpace.workspace_id
}


#outputs
output "monitoring-rgName" {
  value = module.monitoring-rg.rg_name_out
}

output "monitoring-rgLocation" {
  value = module.monitoring-rg.rg_location_out
}

output "App_Insight_Name" {
  description = "The Name of the Pharma-Insight"
  value       = module.Pharma-Insight.app_insight_name
}

output "app_insight_log_analytics" {
  description = "The Log analytics workspace of the Pharma-Insight"
  value       = module.PharmaInsight-WorkSpace.log_analytics
}
 */
