output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "api1_uri" {
  value = azurerm_container_app.containerapp-api1.ingress[0].fqdn
}

output "api2_uri" {
  value = azurerm_container_app.containerapp-api2.ingress[0].fqdn
}

output "ui_uri" {
  value = azurerm_container_app.containerapp-ui.ingress[0].fqdn
}

output "frontdoor_endpoint" {
  value = azurerm_cdn_frontdoor_endpoint.fd-endpoint.host_name
}

 