# Create a resource group
resource "azurerm_resource_group" "lng_udacity" {
  name     = var.resource_group_name
  location = var.location
  tags = var.tags
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "lng_udacity" {
  name                = "lng_udacity_vnet"
  resource_group_name = azurerm_resource_group.lng_udacity.name
  location            = azurerm_resource_group.lng_udacity.location
  address_space       = ["10.0.0.0/16"]
  tags = var.tags
}


resource "azurerm_subnet" "lng_udacity" {
  name                 = "lng_udacity_subnet"
  resource_group_name  = azurerm_resource_group.lng_udacity.name
  virtual_network_name = azurerm_virtual_network.lng_udacity.name
  address_prefixes     = ["10.0.1.0/24"]

  delegation {
    name = "delegation"

    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
    }
  }
}


resource "azurerm_network_security_group" "lng_udacity" {
  name                = "lng_udacity_nsg"
  location            = azurerm_resource_group.lng_udacity.location
  resource_group_name = azurerm_resource_group.lng_udacity.name

  security_rule {
    name                       = "allowInternalVnet"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = azurerm_subnet.lng_udacity.address_prefixes
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "DenyInternet"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Denny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  tags = var.tags
}

resource "azurerm_subnet_network_security_group_association" "lng_udacity" {
  subnet_id                 = azurerm_subnet.lng_udacity.id
  network_security_group_id = azurerm_network_security_group.lng_udacity.id

}

# resource "azurerm_network_interface" "lng_udacity" {
#   name                = "lng_udacity_nic"
#   location            = azurerm_resource_group.lng_udacity.location
#   resource_group_name = azurerm_resource_group.lng_udacity.name

#   ip_configuration {
#     name                          = "internal"
#     subnet_id                     = azurerm_subnet.lng_udacity.id
#     private_ip_address_allocation = "Dynamic"
#   }
#   tags = var.tags
# }

resource "azurerm_public_ip" "lng_udacity" {
  name                = "lng_udacity_PIP"
  location            = azurerm_resource_group.lng_udacity.location
  resource_group_name = azurerm_resource_group.lng_udacity.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

resource "azurerm_lb" "lng_udacity" {
  name                = "lng_udacity_lb"
  location            = azurerm_resource_group.lng_udacity.location
  resource_group_name = azurerm_resource_group.lng_udacity.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.lng_udacity.id
  }
  tags = var.tags
}

resource "azurerm_lb_backend_address_pool" "lng_udacity" {
  loadbalancer_id = azurerm_lb.lng_udacity.id
  name            = "lng_udacity_BackEndAddressPool"
}


resource "azurerm_lb_backend_address_pool_address" "lng_udacity" {
  name                    = "lng_udacity_be_pool_addr"
  backend_address_pool_id = azurerm_lb_backend_address_pool.lng_udacity.id
  virtual_network_id      = azurerm_virtual_network.lng_udacity.id
  ip_address              = "10.0.1.10"
}


# resource "azurerm_availability_set" "lng_udacity" {
#   name                = "lng_udacity_aset"
#   location            = azurerm_resource_group.lng_udacity.location
#   resource_group_name = azurerm_resource_group.lng_udacity.name

#   tags = var.tags
# }

resource "azurerm_network_interface" "lng_udacity" {
   count               = var.vms_min
   name                = "acctni${count.index}"
   location            = azurerm_resource_group.lng_udacity.location
   resource_group_name = azurerm_resource_group.lng_udacity.name

   ip_configuration {
     name                          = "lng_udacity_Configuration"
     subnet_id                     = azurerm_subnet.lng_udacity.id
     private_ip_address_allocation = "dynamic"
   }
   tags = var.tags
 }

 resource "azurerm_managed_disk" "lng_udacity" {
   count                = var.vms_min
   name                 = "datadisk_existing_${count.index}"
   location             = azurerm_resource_group.lng_udacity.location
   resource_group_name  = azurerm_resource_group.lng_udacity.name
   storage_account_type = "Standard_LRS"
   create_option        = "Empty"
   disk_size_gb         = "20480"
   tags = var.tags
 }

 resource "azurerm_availability_set" "lng_udacity" {
   name                         = "lng_udacity_vmsavset"
   location                     = azurerm_resource_group.lng_udacity.location
   resource_group_name          = azurerm_resource_group.lng_udacity.name
   platform_fault_domain_count  = var.vms_min
   platform_update_domain_count = var.vms_min
   managed                      = true
   tags = var.tags
 }

data "azurerm_resource_group" "packer_image" {
  name                = var.packer_resource_group_name
}

data "azurerm_image" "packer_image" {
  name                = var.packer_image_name
  resource_group_name = data.azurerm_resource_group.packer_image.name
}

 resource "azurerm_linux_virtual_machine" "lng_udacity" {
   count                 = var.vms_min
   name                  = "lng_udacity_nic${count.index}"
   location              = azurerm_resource_group.lng_udacity.location
   availability_set_id   = azurerm_availability_set.lng_udacity.id
   resource_group_name   = azurerm_resource_group.lng_udacity.name
   network_interface_ids = [element(azurerm_network_interface.lng_udacity.*.id, count.index)]
   size               = "Standard_DS1_v2"
   admin_username = var.admin_username
   admin_password = var.admin_password
   computer_name  = var.computer_name
   tags = var.tags

   # Uncomment this line to delete the OS disk automatically when deleting the VM
   # delete_os_disk_on_termination = true

   # Uncomment this line to delete the data disks automatically when deleting the VM
   # delete_data_disks_on_termination = true
   source_image_id = data.azurerm_image.packer_image.id 
   

   os_disk {
     name              = "lng_udacity_osdisk${count.index}"
     caching           = "ReadWrite"
     storage_account_type              = "Standard_LRS"
   }



 }