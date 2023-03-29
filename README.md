
This repo contains a sample on how to use Terraform to create the following resources:
* Resource Group - that includes the following resources
* VNET with one subnet for the Private Link Service and another one for the Azure Container Apps Environment
* Container Registry - this sample uses a mcr hello world container image so the registry is not really used, but glues containers apps and the registry with a managed identity for the CI/CD process
* Log Analytics Workspace - to store the logs
* Application insights
* Key Vault
* Managed Identity to enable Container Apps access the Container Registry
* Container Apps Environment with internal networking (for an existing VNET)
* Container App with an API 1 and ingress limited to the Container App Environment
* Container App with an API 2 and ingress limited to the Container App Environment
* Container App with the UI and ingress limited to the VNet. API1 and API2 URI's are passed to this App with env vars.
* Private Link service for Container App Environment - after deploying the resource you must approve the private link connection for the sample to work. You may use the CLI with the command: az network private-endpoint-connection approve
* Front Door to expose the UI to the public

Reference:
* [Container Apps documentation](https://learn.microsoft.com/en-us/azure/container-apps/)
* [Quickstart - deploy an API](https://learn.microsoft.com/en-us/azure/container-apps/quickstart-code-to-cloud)
* [Quickstart - deploy the UI](https://learn.microsoft.com/en-us/azure/container-apps/communicate-between-microservices)
* [Quickstart - Terraform with Azure](https://learn.microsoft.com/en-us/azure/developer/terraform/create-resource-group)
* [Landing Zone Accelerator for Azure Container Apps](https://github.com/Azure/ACA-Landing-Zone-Accelerator)
* [Terraform provider for Container Apps](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app)
* [Terraform provider for Key Vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault)
* [Terraform provider for Front Door](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_origin)

This sample was inspired by [this excelent article](https://techcommunity.microsoft.com/t5/fasttrack-for-azure/integrating-azure-front-door-waf-with-azure-container-apps/ba-p/3729081)! If you are looking for a bicep equivalent and/or more architecture details please use this article. 