resource "azurerm_public_ip" "acme-public-ip-webserver-a" {
  name                = "acme-public-ip-webserver-a"
  location            = azurerm_resource_group.acme-rg.location
  resource_group_name = azurerm_resource_group.acme-rg.name
  allocation_method   = "Static"

  tags = {
    environment = "acme-env"
  }
}

resource "azurerm_public_ip" "acme-public-ip-webserver-b" {
  name                = "acme-public-ip-webserver-b"
  location            = azurerm_resource_group.acme-rg.location
  resource_group_name = azurerm_resource_group.acme-rg.name
  allocation_method   = "Static"

  tags = {
    environment = "acme-env"
  }
}


# Create storage account for boot diagnostics
resource "azurerm_storage_account" "acme_storage_account" {
  name                     = "diag${random_id.random_id.hex}"
  location                 = azurerm_resource_group.acme-rg.location
  resource_group_name      = azurerm_resource_group.acme-rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Generate random text for a unique storage account name
resource "random_id" "random_id" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.acme-rg.name
  }

  byte_length = 8
}

resource "random_password" "password" {
  length      = 20
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
  min_special = 1
  special     = true
}

resource "random_pet" "prefix" {
  prefix = var.prefix
  length = 1
}

# Create Network Security Group and rules
resource "azurerm_network_security_group" "werbserver-nsg" {
  name                = "webserver-nsg"
  location            = azurerm_resource_group.acme-rg.location
  resource_group_name = azurerm_resource_group.acme-rg.name

  security_rule {
    name                       = "RDP"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "web"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# WEBSERVER-A

# Create network interface
resource "azurerm_network_interface" "webserver-a-nic" {
  name                = "webserver-a-nic"
  location            = azurerm_resource_group.acme-rg.location
  resource_group_name = azurerm_resource_group.acme-rg.name

  ip_configuration {
    name                          = "web-server-a-nic-configuration"
    subnet_id                     = azurerm_subnet.public_subnet_a.id
    private_ip_address_allocation = "Static"
    #public_ip_address_id          = azurerm_public_ip.acme-public-ip-webserver-a.id
    private_ip_address = "10.0.11.11"
    private_ip_address_version = "IPv4"
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "webserver-a-nic-nsg" {
  network_interface_id      = azurerm_network_interface.webserver-a-nic.id
  network_security_group_id = azurerm_network_security_group.werbserver-nsg.id
}


# Create virtual machine
resource "azurerm_windows_virtual_machine" "webserver-a" {
  name                  = "webserver-a"
  admin_username        = "azureuser"
  admin_password        = random_password.password.result
  location              = azurerm_resource_group.acme-rg.location
  resource_group_name   = azurerm_resource_group.acme-rg.name
  network_interface_ids = [azurerm_network_interface.webserver-a-nic.id]
  size                  = "Standard_DS1_v2"
  zone = 1

  os_disk {
    name                 = "webserver-a-disk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.acme_storage_account.primary_blob_endpoint
  }
}

# Install IIS web server to the virtual machine
resource "azurerm_virtual_machine_extension" "webserver-a-install" {
  name                       = "${random_pet.prefix.id}-a-wsi"
  virtual_machine_id         = azurerm_windows_virtual_machine.webserver-a.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.8"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
      "commandToExecute": "powershell -ExecutionPolicy Unrestricted Install-WindowsFeature -Name Web-Server -IncludeAllSubFeature -IncludeManagementTools; powershell Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.htm\" -Value $($env:computername)"
    }
  SETTINGS
}



# WEBSERVER-B

# Create network interface
resource "azurerm_network_interface" "webserver-b-nic" {
  name                = "webserver-b-nic"
  location            = azurerm_resource_group.acme-rg.location
  resource_group_name = azurerm_resource_group.acme-rg.name

  ip_configuration {
    name                          = "web-server-b-nic-configuration"
    subnet_id                     = azurerm_subnet.public_subnet_b.id
    private_ip_address_allocation = "Static"
    #public_ip_address_id          = azurerm_public_ip.acme-public-ip-webserver-b.id
    private_ip_address = "10.0.12.11"
    private_ip_address_version = "IPv4"
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "webserver-b-nic-nsg" {
  network_interface_id      = azurerm_network_interface.webserver-b-nic.id
  network_security_group_id = azurerm_network_security_group.werbserver-nsg.id
}


# Create virtual machine
resource "azurerm_windows_virtual_machine" "webserver-b" {
  name                  = "webserver-b"
  admin_username        = "azureuser"
  admin_password        = random_password.password.result
  location              = azurerm_resource_group.acme-rg.location
  resource_group_name   = azurerm_resource_group.acme-rg.name
  network_interface_ids = [azurerm_network_interface.webserver-b-nic.id]
  size                  = "Standard_DS1_v2"
  zone = 2
  
  os_disk {
    name                 = "webserver-b-disk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.acme_storage_account.primary_blob_endpoint
  }
}

# Install IIS web server to the virtual machine
resource "azurerm_virtual_machine_extension" "webserver-b-install" {
  name                       = "${random_pet.prefix.id}-b-wsi"
  virtual_machine_id         = azurerm_windows_virtual_machine.webserver-b.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.8"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
      "commandToExecute": "powershell -ExecutionPolicy Unrestricted Install-WindowsFeature -Name Web-Server -IncludeAllSubFeature -IncludeManagementTools; powershell Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.htm\" -Value $($env:computername)"
    }
  SETTINGS
}

