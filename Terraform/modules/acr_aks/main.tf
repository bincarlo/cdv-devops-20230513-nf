resource "azurerm_container_registry" "acr" {
  #   name                = "${var.prefix}${var.application}${var.environment}acr"
  name                = "${var.prefix}terraformactionsnf${var.environment}acr"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Premium"

  #Container registry > Setting > Access keys > Admin user > Enabled
  admin_enabled = true
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.prefix}-${var.application}-${var.environment}-aks"
  resource_group_name = var.resource_group_name
  location            = var.location
  dns_prefix          = "${var.prefix}-${var.application}-aks"

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_B2s"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    application = var.application
    environment = var.environment
    owner       = var.owner
  }
}

resource "azurerm_role_assignment" "aks_role" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}
