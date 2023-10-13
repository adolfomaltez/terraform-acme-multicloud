resource "azurerm_virtual_network" "acme-vnet" {
  name                = "acme-vnet"
  location            = azurerm_resource_group.acme-rg.location
  resource_group_name = azurerm_resource_group.acme-rg.name
  address_space       = ["10.0.0.0/16"]

  tags = {
    environment = "acme-env"
  }
}

resource "azurerm_subnet" "public_subnet_a" {
  name                 = "public_subnet_a"
  resource_group_name  = azurerm_resource_group.acme-rg.name
  virtual_network_name = azurerm_virtual_network.acme-vnet.name
  address_prefixes     = ["10.0.11.0/24"]
}

resource "azurerm_subnet" "public_subnet_b" {
  name                 = "public_subnet_b"
  resource_group_name  = azurerm_resource_group.acme-rg.name
  virtual_network_name = azurerm_virtual_network.acme-vnet.name
  address_prefixes     = ["10.0.12.0/24"]
}

resource "azurerm_subnet" "private_subnet_a" {
  name                 = "private_subnet_a"
  resource_group_name  = azurerm_resource_group.acme-rg.name
  virtual_network_name = azurerm_virtual_network.acme-vnet.name
  address_prefixes     = ["10.0.21.0/24"]
}

resource "azurerm_subnet" "private_subnet_b" {
  name                 = "private_subnet_b"
  resource_group_name  = azurerm_resource_group.acme-rg.name
  virtual_network_name = azurerm_virtual_network.acme-vnet.name
  address_prefixes     = ["10.0.22.0/24"]
}
