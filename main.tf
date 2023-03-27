data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = "${var.aca_name}rg"
  location = var.location
}

resource "azurerm_log_analytics_workspace" "loganalytics" {
  name                = "${var.aca_name}la"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_application_insights" "appinsights" {
  name                = "${var.aca_name}-appinsights"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  workspace_id        = azurerm_log_analytics_workspace.loganalytics.id
  application_type    = "web"
}

resource "azurerm_container_registry" "acr" {
  name                = "${var.aca_name}acr"
  sku                 = "Standard"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

data "azurerm_subnet" "acasubnet" {
  name                 = "acasubnet"
  virtual_network_name = "alexviei-vnet"
  resource_group_name  = "alexviei-network"
}

resource "azurerm_container_app_environment" "containerappenv" {
  name                       = "${var.aca_name}env"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.loganalytics.id
  infrastructure_subnet_id   = data.azurerm_subnet.acasubnet.id
  internal_load_balancer_enabled = true
}

resource "azurerm_user_assigned_identity" "containerapp" {
  location            = azurerm_resource_group.rg.location
  name                = "${var.aca_name}uai"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_role_assignment" "containerapp" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "acrpull"
  principal_id         = azurerm_user_assigned_identity.containerapp.principal_id
  depends_on = [
    azurerm_user_assigned_identity.containerapp
  ]
}

resource "azurerm_container_app" "containerapp-api1" {
  name                         = "${var.aca_name}-api1"
  container_app_environment_id = azurerm_container_app_environment.containerappenv.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Multiple"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.containerapp.id]
  }

  registry {
    server   = azurerm_container_registry.acr.login_server
    identity = azurerm_user_assigned_identity.containerapp.id
  }

  ingress {
     external_enabled = false
     target_port = 80
     traffic_weight {
       latest_revision = true
       percentage = 100
     }
  }
  template {
    container {
      name   = "helloworldcontainerapp"
      image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }

}

resource "azurerm_container_app" "containerapp-api2" {
  name                         = "${var.aca_name}-api2"
  container_app_environment_id = azurerm_container_app_environment.containerappenv.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Multiple"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.containerapp.id]
  }

  registry {
    server   = azurerm_container_registry.acr.login_server
    identity = azurerm_user_assigned_identity.containerapp.id
  }

  ingress {
     external_enabled = false
     target_port = 80
     traffic_weight {
       latest_revision = true
       percentage = 100
     }
  }
  template {
    container {
      name   = "helloworldcontainerapp"
      image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }

}

resource "azurerm_container_app" "containerapp-ui" {
  name                         = "${var.aca_name}-ui"
  container_app_environment_id = azurerm_container_app_environment.containerappenv.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Multiple"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.containerapp.id]
  }

  registry {
    server   = azurerm_container_registry.acr.login_server
    identity = azurerm_user_assigned_identity.containerapp.id
  }

  ingress {
     external_enabled = true
     target_port = 80
     traffic_weight {
       latest_revision = true
       percentage = 100
     }
  }
  template {
    container {
      name   = "helloworldcontainerapp"
      image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu    = 0.25
      memory = "0.5Gi"
      env {
        name = "API1_URL"
        value = azurerm_container_app.containerapp-api1.ingress[0].fqdn
      }
      env {
        name = "API2_URL"
        value = azurerm_container_app.containerapp-api2.ingress[0].fqdn
      }

      readiness_probe {
        transport = "HTTP"
        port      = 80
      }

      liveness_probe {
        transport = "HTTP"
        port      = 80
      }

      startup_probe {
        transport = "HTTP"
        port      = 80
      }
    }
  }

}


// section for private link service
data "azurerm_lb" "kubernetes-internal" {
  name                = "kubernetes-internal"
  resource_group_name = format("MC_%s-rg_%s_%s", split(".", azurerm_container_app.containerapp-ui.ingress[0].fqdn)[1], split(".", azurerm_container_app.containerapp-ui.ingress[0].fqdn)[1], azurerm_resource_group.rg.location)
}
resource "azurerm_private_link_service" "pls" {
  name                = "${var.aca_name}pls"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  visibility_subscription_ids                 = [data.azurerm_client_config.current.subscription_id]
  load_balancer_frontend_ip_configuration_ids = [data.azurerm_lb.kubernetes-internal.frontend_ip_configuration.0.id]

  nat_ip_configuration {
    name                       = "primary"
    private_ip_address_version = "IPv4"
    subnet_id                  = data.azurerm_subnet.acasubnet.id
    primary                    = true
  }
}


// section for front door service
resource "azurerm_cdn_frontdoor_profile" "fd-profile" {
  depends_on = [azurerm_private_link_service.pls]

  name                = "${var.aca_name}-fdprofile"
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "Premium_AzureFrontDoor"
}
resource "azurerm_cdn_frontdoor_endpoint" "fd-endpoint" {
  name                     = "${var.aca_name}-fdendpoint"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fd-profile.id
}
resource "azurerm_cdn_frontdoor_origin_group" "fd-origin-group" {
  name                     = "${var.aca_name}-fdorigingroup"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fd-profile.id

  load_balancing {
    additional_latency_in_milliseconds = 0
    sample_size                        = 16
    successful_samples_required        = 3
  }
}
resource "azurerm_cdn_frontdoor_route" "fd-route" {
  name                          = "${var.aca_name}-fdroute"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.fd-endpoint.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.fd-origin-group.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.fd-origin.id]

  supported_protocols    = ["Http", "Https"]
  patterns_to_match      = ["/*"]
  forwarding_protocol    = "HttpsOnly"
  link_to_default_domain = true
  https_redirect_enabled = true
}
resource "azurerm_cdn_frontdoor_origin" fd-origin {
  name                           = "${var.aca_name}-fdorigin"
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.fd-origin-group.id
  enabled                        = true
  host_name                      = azurerm_container_app.containerapp-ui.ingress[0].fqdn
  origin_host_header             = azurerm_container_app.containerapp-ui.ingress[0].fqdn
  priority                       = 1
  weight                         = 1000
  certificate_name_check_enabled = true

  private_link {
    request_message        = "Request access for Private Link Origin CDN Frontdoor"
    location               = azurerm_resource_group.rg.location
    private_link_target_id = azurerm_private_link_service.pls.id
  }
}
