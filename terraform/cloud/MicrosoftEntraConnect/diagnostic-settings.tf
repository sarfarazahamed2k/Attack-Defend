# data "azurerm_client_config" "current" {}

# resource "azapi_resource" "diagnostic_settings" {
#   type      = "microsoft.aadiam/diagnosticSettings@2017-04-01"
#   name      = "entraid-setting"
#   parent_id = "/providers/Microsoft.AAD/tenants/${data.azurerm_client_config.current.tenant_id}"

#   body = {
#     properties = {
#       workspaceId = azurerm_log_analytics_workspace.workspace.id
#       logs = [
#         {
#           category = "SignInLogs"
#           enabled  = true
#           retentionPolicy = {
#             days    = 1
#             enabled = true
#           }
#         },
#         {
#           category = "AuditLogs"
#           enabled  = true
#           retentionPolicy = {
#             days    = 1
#             enabled = true
#           }
#         },
#         {
#           category = "NonInteractiveUserSignInLogs"
#           enabled  = true
#           retentionPolicy = {
#             days    = 1
#             enabled = true
#           }
#         },
#         {
#           category = "ServicePrincipalSignInLogs"
#           enabled  = true
#           retentionPolicy = {
#             days    = 1
#             enabled = true
#           }
#         },
#         {
#           category = "ManagedIdentitySignInLogs"
#           enabled  = true
#           retentionPolicy = {
#             days    = 1
#             enabled = true
#           }
#         },
#         {
#           category = "ProvisioningLogs"
#           enabled  = true
#           retentionPolicy = {
#             days    = 1
#             enabled = true
#           }
#         }
#       ]
#     }
#   }
# }
