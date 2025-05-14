resource "azurerm_cdn_frontdoor_profile" "red_team_frontdoor_profile" {
  name                = "red-team-frontdoor"
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "Standard_AzureFrontDoor"
}

resource "azurerm_cdn_frontdoor_endpoint" "default_endpoint" {
  name                     = "default-endpoint"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.red_team_frontdoor_profile.id
  enabled                  = true
}

resource "azurerm_cdn_frontdoor_origin_group" "attack_vm_origin_group" {
  name                     = "attack-vm-origin-group"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.red_team_frontdoor_profile.id

  load_balancing {
    additional_latency_in_milliseconds = 0
    sample_size                        = 1
    successful_samples_required        = 1
  }
}

resource "azurerm_cdn_frontdoor_origin" "attack_vm_origin" {
  name                          = "attack-vm-origin"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.attack_vm_origin_group.id

  enabled                        = true
  host_name                      = azurerm_public_ip.attack_vm_pip.ip_address
  origin_host_header             = azurerm_public_ip.attack_vm_pip.ip_address
  certificate_name_check_enabled = false

  http_port  = 80
  https_port = 443
}

resource "azurerm_cdn_frontdoor_route" "default_route" {
  name                          = "default-route"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.default_endpoint.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.attack_vm_origin_group.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.attack_vm_origin.id]

  supported_protocols    = ["Http", "Https"]
  patterns_to_match      = ["/*"]
  forwarding_protocol    = "HttpOnly"
  link_to_default_domain = true
}
