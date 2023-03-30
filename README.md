
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


#App lifecycle management topics
__1. Complete environment(s) creation using the IaC based blueprints__
* [Environment](https://learn.microsoft.com/en-us/azure/container-apps/environment), [custom VNet](https://learn.microsoft.com/en-us/azure/container-apps/networking#custom-vnet-configuration), [ingress](https://learn.microsoft.com/en-us/azure/container-apps/ingress-overview) and [proxying](https://learn.microsoft.com/en-us/azure/container-apps/firewall-integration), [network security](https://learn.microsoft.com/en-us/azure/container-apps/firewall-integration), [identities](https://learn.microsoft.com/en-us/azure/container-apps/managed-identity?tabs=portal%2Cdotnet), [secrets](https://learn.microsoft.com/en-us/azure/container-apps/manage-secrets?tabs=arm-template), [Arc](https://learn.microsoft.com/en-us/azure/container-apps/azure-arc-overview)
* [Terraform based quick start](https://github.com/vieiraae/aca-blueprint)

__2. Inner loop App development__
* App bootstrapping using predefined templates ([samples](https://learn.microsoft.com/en-us/azure/container-apps/samples), [azd templates](https://azure.github.io/awesome-azd/), private repos)
* [Dapr](https://learn.microsoft.com/en-us/azure/container-apps/dapr-overview?tabs=bicep1%2Cyaml), [authentication](https://learn.microsoft.com/en-us/azure/container-apps/authentication-azure-active-directory), [event driven](https://learn.microsoft.com/en-us/azure/container-apps/microservices-dapr-bindings?pivots=nodejs), [background processing](https://learn.microsoft.com/en-us/azure/container-apps/background-processing?tabs=bash)
* [Visual Studio Code](https://learn.microsoft.com/en-us/azure/container-apps/deploy-visual-studio-code) (+ [extension](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-azurecontainerapps)), [cloud build](https://learn.microsoft.com/en-us/azure/container-apps/quickstart-code-to-cloud?tabs=bash%2Ccsharp&pivots=acr-remote), [local build](https://learn.microsoft.com/en-us/azure/container-apps/quickstart-code-to-cloud?tabs=bash%2Ccsharp&pivots=docker-local), [Visual Studio](https://learn.microsoft.com/en-us/azure/container-apps/deploy-visual-studio)

__3. App delivery with CI/CD workflows__
* [GitHub Actions](https://learn.microsoft.com/en-us/azure/container-apps/github-actions), [Azure Pipelines](https://learn.microsoft.com/en-us/azure/container-apps/azure-pipelines), [CI/CD with CLI](https://learn.microsoft.com/en-us/azure/container-apps/github-actions)

__4. Operations__
* [CLI](https://learn.microsoft.com/en-us/cli/azure/containerapp?view=azure-cli-latest&preserve-view=true), [revisions](https://learn.microsoft.com/en-us/azure/container-apps/revisions-manage?tabs=bash) [zero downtime](https://learn.microsoft.com/en-us/azure/container-apps/application-lifecycle-management), [traffic splitting](https://learn.microsoft.com/en-us/azure/container-apps/traffic-splitting?pivots=azure-cli), [scaling](https://learn.microsoft.com/en-us/azure/container-apps/scale-app?pivots=azure-cli), [health probes](https://learn.microsoft.com/en-us/azure/container-apps/health-probes?tabs=arm-template), [zone redundancy](https://learn.microsoft.com/en-us/azure/container-apps/disaster-recovery?tabs=bash)
* [Observability](https://learn.microsoft.com/en-us/azure/container-apps/observability), [log streaming](https://learn.microsoft.com/en-us/azure/container-apps/log-streaming?tabs=bash), [container console](https://learn.microsoft.com/en-us/azure/container-apps/container-console?tabs=bash), [alerts](https://learn.microsoft.com/en-us/azure/container-apps/alerts), [OpenTelemetry](https://learn.microsoft.com/en-us/azure/azure-monitor/app/opentelemetry-enable?tabs=net), [billing](https://learn.microsoft.com/en-us/azure/container-apps/billing)
