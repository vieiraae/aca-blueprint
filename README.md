
This repo contains a sample on how to use Terraform to create the following resources:
* Resource Group - that includes the following resources
* Container Registry - this sample uses a mcr hello world container image so the registry is not really used, but glues containers apps and the registry with a managed identity for the CI/CD process
* Log Analytics Workspace - to store the logs
* Managed Identity to enable Container Apps access the Container Registry
* Container Apps Environment with internal networking
* Container App with an API 1 and ingress limited to the Container App Environment
* Container App with an API 2 and ingress limited to the Container App Environment
* Container App with the UI and ingress limited to the VNet. API1 and API2 URI's are passed to this App with env vars.

Reference:
* [Container Apps documentation](https://learn.microsoft.com/en-us/azure/container-apps/)
* [Quickstart - deploy an API](https://learn.microsoft.com/en-us/azure/container-apps/quickstart-code-to-cloud)
* [Quickstart - deploy the UI](https://learn.microsoft.com/en-us/azure/container-apps/communicate-between-microservices)
* [Quickstart - Terraform with Azure](https://learn.microsoft.com/en-us/azure/developer/terraform/create-resource-group)
* [Terraform provider for Container Apps](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app)


