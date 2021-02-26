###################################################################
#                                                                 #
#	Main NET                                                      #
#                                                                 #
###################################################################

# Creación de red principal
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network

resource "azurerm_virtual_network" "mainNet" {
    name                = "unirvirtualnetwork"
    address_space       = ["10.1.0.0/16"]
    location            = azurerm_resource_group.unirRG.location
    resource_group_name = azurerm_resource_group.unirRG.name

    tags = {
        environment = "UNIR"
    }
}

###################################################################
#
#	Bastión Network
#	Azure reserva las IP´s .0, .1, .2, .3, y .255
#
###################################################################


# Creación de subnet para bastión.
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet

resource "azurerm_subnet" "bastionSubNet" {
    name                   = "bastionsubnet"
    resource_group_name    = azurerm_resource_group.unirRG.name
    virtual_network_name   = azurerm_virtual_network.mainNet.name
    address_prefixes       = ["10.1.4.0/24"]

}

# Create NIC para bastión.
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface

resource "azurerm_network_interface" "bastionNIC" {
  name                = "bastionnic"  
  location            = azurerm_resource_group.unirRG.location
  resource_group_name = azurerm_resource_group.unirRG.name
  
  depends_on = [azurerm_public_ip.bastionPublicIP]

    ip_configuration {
	  name                           = "bastionnicconf"
      subnet_id                      = azurerm_subnet.bastionSubNet.id 
      private_ip_address_allocation  = "Static"
      private_ip_address             = "10.1.4.4"
	  public_ip_address_id           = azurerm_public_ip.bastionPublicIP.id
    }

    tags = {
        environment = "UNIR"
    }

}

# IP pública
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip

resource "azurerm_public_ip" "bastionPublicIP" {
  name                = "bastionpublicip"
  location            = azurerm_resource_group.unirRG.location
  resource_group_name = azurerm_resource_group.unirRG.name
  allocation_method   = "Static"

    tags = {
        environment = "UNIR"
    }

}

###################################################################
#
#	K8S Network
#	Azure reserva las IP´s .0, .1, .2, .3, y .255
#
###################################################################


# Creación de subnet para Kubernetes.
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet

resource "azurerm_subnet" "k8sSubNet" {
    name                   = "k8ssubnet"
    resource_group_name    = azurerm_resource_group.unirRG.name
    virtual_network_name   = azurerm_virtual_network.mainNet.name
    address_prefixes       = ["10.1.1.0/24"]

}

# Create NIC para Kubernetes Master
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface

resource "azurerm_network_interface" "k8sMasterNIC" {
  name                = "k8smasternic"  
  location            = azurerm_resource_group.unirRG.location
  resource_group_name = azurerm_resource_group.unirRG.name

    ip_configuration {
	  name                           = "k8smasternicconf"
      subnet_id                      = azurerm_subnet.k8sSubNet.id 
      private_ip_address_allocation  = "Static"
      private_ip_address             = "10.1.1.4"
      public_ip_address_id           = azurerm_public_ip.masterPublicIP.id
    }

    tags = {
        environment = "UNIR"
    }

}

# IP pública Master
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip

resource "azurerm_public_ip" "masterPublicIP" {
  name                = "masterpublicip"
  location            = azurerm_resource_group.unirRG.location
  resource_group_name = azurerm_resource_group.unirRG.name
  allocation_method   = "Static"

    tags = {
        environment = "UNIR"
    }

}

# Create NIC para Kubernetes Worker
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface

resource "azurerm_network_interface" "k8sBack1NIC" {
	name                = "k8sback1nic"  
	location            = azurerm_resource_group.unirRG.location
	resource_group_name = azurerm_resource_group.unirRG.name

    ip_configuration {
		name                           = "k8sback1nicconf"
		subnet_id                      = azurerm_subnet.k8sSubNet.id 
		private_ip_address_allocation  = "Static"
		private_ip_address             = "10.1.1.5"
    }

    tags = {
        environment = "UNIR"
    }

}

# Create NIC para Kubernetes Worker
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface

resource "azurerm_network_interface" "k8sBack2NIC" {
	name                = "k8sback2nic"  
	location            = azurerm_resource_group.unirRG.location
	resource_group_name = azurerm_resource_group.unirRG.name

    ip_configuration {
		name                           = "k8sback2nicconf"
		subnet_id                      = azurerm_subnet.k8sSubNet.id 
		private_ip_address_allocation  = "Static"
		private_ip_address             = "10.1.1.6"
    }

    tags = {
        environment = "UNIR"
    }

}

