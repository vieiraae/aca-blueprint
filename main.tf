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

resource "azurerm_container_app" "containerapp" {
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