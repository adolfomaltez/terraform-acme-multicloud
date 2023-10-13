resource "azurerm_public_ip" "acme-public-ip" {
  name                = "acme-public-ip"
  location            = azurerm_resource_group.acme-rg.location
  resource_group_name = azurerm_resource_group.acme-rg.name
  allocation_method   = "Static"
  #fqdn = 

  tags = {
    environment = "acme-env"
  }
}

resource "azurerm_lb" "acme-lb" {
  name                = "acme-lb"
  location            = azurerm_resource_group.acme-rg.location
  resource_group_name = azurerm_resource_group.acme-rg.name

  frontend_ip_configuration {
    name                 = "acme-lb-frontend-ip"
    public_ip_address_id = azurerm_public_ip.acme-public-ip.id
  }

  tags = {
    environment = "acme-env"
  }
}

resource "azurerm_lb_backend_address_pool" "acme-lb-backend-pool" {
  loadbalancer_id     = azurerm_lb.acme-lb.id
  name                = "acme-lb-backend-pool"
  virtual_network_id = azurerm_virtual_network.acme-vnet.id
  #backend_ip_configurations = azurerm_network_interface.webserver-a-nic.private_ip_address
}


#LB Probe - Checks to see which VMs are healthy and available
resource "azurerm_lb_probe" "load_balancer_probe" {
  #location            = "${var.azure_region_fullname}"
  #resource_group_name = "${azurerm_resource_group.resource_group.name}"
  loadbalancer_id     = azurerm_lb.acme-lb.id
  name                = "HTTP"
  port                = 80
}


# Load Balancer Rule
resource "azurerm_lb_rule" "load_balancer_http_rule" {
  #location                       = "${var.azure_region_fullname}"
  #resource_group_name            = "${azurerm_resource_group.resource_group.name}"
  loadbalancer_id                = azurerm_lb.acme-lb.id
  name                           = "HTTPRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "acme-lb-frontend-ip"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.acme-lb-backend-pool.id]
  probe_id                       = azurerm_lb_probe.load_balancer_probe.id
  depends_on                     = [azurerm_lb_probe.load_balancer_probe]
}

resource "azurerm_network_interface_backend_address_pool_association" "webserver_a_nic_lb_associate" {
  network_interface_id    = azurerm_network_interface.webserver-a-nic.id
  ip_configuration_name   = azurerm_network_interface.webserver-a-nic.ip_configuration[0].name
  backend_address_pool_id = azurerm_lb_backend_address_pool.acme-lb-backend-pool.id
}

resource "azurerm_network_interface_backend_address_pool_association" "webserver_b_nic_lb_associate" {
  network_interface_id    = azurerm_network_interface.webserver-b-nic.id
  ip_configuration_name   = azurerm_network_interface.webserver-b-nic.ip_configuration[0].name
  backend_address_pool_id = azurerm_lb_backend_address_pool.acme-lb-backend-pool.id
}