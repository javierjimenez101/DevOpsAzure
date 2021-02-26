output "BastionPublicIP" {
	depends_on = [azurerm_public_ip.bastionPublicIP,azurerm_linux_virtual_machine.bastionServer]
	value = azurerm_public_ip.bastionPublicIP.ip_address
}

output "MasterPublicIP" {
	depends_on = [azurerm_public_ip.masterPublicIP,azurerm_linux_virtual_machine.k8sMasterServer]
	value = azurerm_public_ip.masterPublicIP.ip_address
}