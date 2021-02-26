## Security group
## https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group

###################################################################
#
#	Bastión Security Group
#
#	- Acceso SSH al servidor bastión
#	- Acceso limitado a una IP determinada
#
###################################################################

# Asignamos nombre a la Network Security Group y Resource Group.
resource "azurerm_network_security_group" "bastionSecGroup" {
    name                = "bastionSecGroup"
    location            = azurerm_resource_group.unirRG.location
    resource_group_name = azurerm_resource_group.unirRG.name#

    tags = {
        environment = "UNIR"
    }
}

# Regla que permite en exclusiva el acceso desde la dirección IP 83.38.56.77 a todos los puertos y protocolos.
resource "azurerm_network_security_rule" "bastionRegIp" {
  name                        = "bastionRegIp"
  priority                    = 1001
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "*"
  source_port_range          = "*"
  destination_port_range     = "*"
  source_address_prefix      = "83.38.56.77"
  destination_address_prefix = "*"
  resource_group_name         = azurerm_resource_group.unirRG.name
  network_security_group_name = azurerm_network_security_group.bastionSecGroup.name
}

# Asignando Network Security Group a la interfaz de red del bastión.
resource "azurerm_network_interface_security_group_association" "bastionSGAssociation" {
  network_interface_id      = azurerm_network_interface.bastionNIC.id
  network_security_group_id = azurerm_network_security_group.bastionSecGroup.id
}

###################################################################
#
#	Master Security Group
#
#	- Acceso HTTP al servidor Master desde Internet
#	
#
###################################################################

# Asignamos nombre a la Network Security Group y Resource Group.
resource "azurerm_network_security_group" "masterSecGroup" {
    name                = "mastersSecGroup"
    location            = azurerm_resource_group.unirRG.location
    resource_group_name = azurerm_resource_group.unirRG.name

    tags = {
        environment = "UNIR"
    }
}

# Regla que permite el acceso desde la dirección IP 83.38.56.77 a todos los puertos y protocolos.
resource "azurerm_network_security_rule" "registeredIP" {
  name                       = "httpPublic"
  priority                   = 1001
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "*"
  source_port_range          = "*"
  destination_port_range     = "*"
  source_address_prefix      = "83.38.56.77"
  destination_address_prefix = "*"
  resource_group_name         = azurerm_resource_group.unirRG.name
  network_security_group_name = azurerm_network_security_group.masterSecGroup.name
}

# Regla que permite el acceso al servidor bastión a la red de servidiores K8S
resource "azurerm_network_security_rule" "internalBastion" {
  name                       = "internal"
  priority                   = 1002
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "*"
  source_port_range          = "*"
  destination_port_range     = "*"
  source_address_prefix      = "10.1.4.4/32"
  destination_address_prefix = "*"
  resource_group_name         = azurerm_resource_group.unirRG.name
  network_security_group_name = azurerm_network_security_group.masterSecGroup.name
}

# Regla que permite el acceso entre servidores contenidos en la red K8S.
resource "azurerm_network_security_rule" "internalNet" {
  name                       = "internal"
  priority                   = 1003
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "*"
  source_port_range          = "*"
  destination_port_range     = "*"
  source_address_prefix      = "10.1.0.0/16"
  destination_address_prefix = "*"
  resource_group_name         = azurerm_resource_group.unirRG.name
  network_security_group_name = azurerm_network_security_group.masterSecGroup.name
}

# Asignando reglas a la interfaz de red del servidor.
resource "azurerm_network_interface_security_group_association" "masterSGAssociation" {
  network_interface_id      = azurerm_network_interface.k8sMasterNIC.id
  network_security_group_id = azurerm_network_security_group.masterSecGroup.id
}