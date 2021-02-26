# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine

###################################################################
#                                                                 #
#	Bastion Server                                                #
# - Nombre: bastionServer                                         #
# - Tipo VM: Definida en el archivo vars.tf para vm_bastion_size  #
# - Usuario: adminunir                                            #
###################################################################

resource "azurerm_linux_virtual_machine" "bastionServer" {
    name                = "bastionServer"
    resource_group_name = azurerm_resource_group.unirRG.name
    location            = azurerm_resource_group.unirRG.location
    size                = var.vm_bastion_size
    admin_username      = "adminunir"
    network_interface_ids = [ azurerm_network_interface.bastionNIC.id ]
    disable_password_authentication = true
	
	depends_on = [azurerm_network_interface.bastionNIC,azurerm_linux_virtual_machine.k8sMasterServer]

    admin_ssh_key {
        username   = "adminunir"
        public_key = file(".ssh/id_rsa_azure_unir.pub")
    }
	
    os_disk {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    plan {
        name      = "centos-8-stream-free"
        product   = "centos-8-stream-free"
        publisher = "cognosys"
    }

    source_image_reference {
        publisher = "cognosys"
        offer     = "centos-8-stream-free"
        sku       = "centos-8-stream-free"
        version   = "1.2019.0810"
    }

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.stAccount.primary_blob_endpoint
    }

    tags = {
        environment = "UNIR"
    }

}

# Provisión de archivos necesarios para la automatización de los despliegues.
resource "null_resource" "bastion_deployer" {
	# Dependencia previa a la provisión.
	depends_on = [
	  	azurerm_linux_virtual_machine.bastionServer
	]

	# Parámetros para la conexión con el servidor (basada en claves asimétricas).
	connection {
		type  = "ssh"
		host  = azurerm_public_ip.bastionPublicIP.ip_address
		user  = "adminunir"
		port  = 22
		private_key = file(".ssh/id_rsa_azure_unir")
		agent = false
	}

	# Despliegue fichero con la clave privada.
	provisioner "file" {
		source      = ".ssh/id_rsa_azure_unir"
		destination = "/home/adminunir/.ssh/id_rsa_azure_unir"
	}

    # Despliegue script de despliegue de componentes.
	provisioner "file" {
		source      = "../scripts/bastion_deployment.sh"
		destination = "/home/adminunir/bastion_deployment.sh"
	}
    
	# Generando archivo con scripts shell, Ansible y Kubernetes.
	provisioner "local-exec" {
		command = "tar -czf ../DevOpsUnir.tar.gz ../scripts ../Ansible ../Kubernetes"
	}
    
	# Despliegue archivo con scripts.
	provisioner "file" {
		source      = "../DevOpsUnir.tar.gz"
		destination = "/home/adminunir/DevOpsUnir.tar.gz"
	}
    
    # Borrado archivo temporal.
    provisioner "local-exec" {
		command = "rm ../DevOpsUnir.tar.gz"
	}
    
	# Modificación permisos en archivos.
	provisioner "remote-exec" {
		inline = [
			"chmod 700 /home/adminunir/.ssh/id_rsa_azure_unir",
			"chmod +x /home/adminunir/bastion_deployment.sh"
		]
	}
    
	# Ejecución script inicio del despliegue.
	provisioner "local-exec" {
		command = "ssh -o 'StrictHostKeyChecking no' -i .ssh/id_rsa_azure_unir adminunir@${azurerm_public_ip.bastionPublicIP.ip_address} '/home/adminunir/bastion_deployment.sh'"
	}
	
}

######################################################################
#                                                                    #
#	Master Server                                                    #
# - Nombre: k8smasterserver                                          #
# - Tipo VM: Definida en el archivo vars.tf para vm_k8s_master_size  #
# - Usuario: adminunir                                               #
######################################################################

resource "azurerm_linux_virtual_machine" "k8sMasterServer" {
    name                = "k8smasterserver"
    resource_group_name = azurerm_resource_group.unirRG.name
    location            = azurerm_resource_group.unirRG.location
    size                = var.vm_k8s_master_size
    admin_username      = "adminunir"
    network_interface_ids = [ azurerm_network_interface.k8sMasterNIC.id ]
    disable_password_authentication = true
	
	depends_on = [
	  azurerm_linux_virtual_machine.k8sBackServer1,
	  azurerm_linux_virtual_machine.k8sBackServer2
    ]

    admin_ssh_key {
        username   = "adminunir"
        public_key = file(".ssh/id_rsa_azure_unir.pub")
    }

    os_disk {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    plan {
        name      = "centos-8-stream-free"
        product   = "centos-8-stream-free"
        publisher = "cognosys"
    }

    source_image_reference {
        publisher = "cognosys"
        offer     = "centos-8-stream-free"
        sku       = "centos-8-stream-free"
        version   = "1.2019.0810"
    }

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.stAccount.primary_blob_endpoint
    }
	
	
    tags = {
        environment = "UNIR"
    }

}

# Creación disco NFS
resource "azurerm_managed_disk" "nfsDisk" {
  name                 = "nfs-disk1"
  location             = azurerm_resource_group.unirRG.location
  resource_group_name  = azurerm_resource_group.unirRG.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 2
}

# Asignación disco NFS
resource "azurerm_virtual_machine_data_disk_attachment" "nfsDiskAttachment" {
  managed_disk_id    = azurerm_managed_disk.nfsDisk.id
  virtual_machine_id = azurerm_linux_virtual_machine.k8sMasterServer.id
  lun                = "10"
  caching            = "ReadWrite"
}

######################################################################
#                                                                    #
#	Worker Server                                                    #
# - Nombre: k8sbackserver1                                           #
# - Tipo VM: Definida en el archivo vars.tf para vm_k8s_back_size    #
# - Usuario: adminunir                                               #
######################################################################

resource "azurerm_linux_virtual_machine" "k8sBackServer1" {
    name                = "k8sbackserver1"
    resource_group_name = azurerm_resource_group.unirRG.name
    location            = azurerm_resource_group.unirRG.location
    size                = var.vm_k8s_back_size
    admin_username      = "adminunir"
    network_interface_ids = [ azurerm_network_interface.k8sBack1NIC.id ]
    disable_password_authentication = true

    admin_ssh_key {
        username   = "adminunir"
        public_key = file(".ssh/id_rsa_azure_unir.pub")
    }

    os_disk {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    plan {
        name      = "centos-8-stream-free"
        product   = "centos-8-stream-free"
        publisher = "cognosys"
    }

    source_image_reference {
        publisher = "cognosys"
        offer     = "centos-8-stream-free"
        sku       = "centos-8-stream-free"
        version   = "1.2019.0810"
    }

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.stAccount.primary_blob_endpoint
    }
	
    tags = {
        environment = "UNIR"
    }

}

######################################################################
#                                                                    #
#	Worker Server                                                    #
# - Nombre: k8sbackserver2                                           #
# - Tipo VM: Definida en el archivo vars.tf para vm_k8s_back_size    #
# - Usuario: adminunir                                               #
######################################################################

resource "azurerm_linux_virtual_machine" "k8sBackServer2" {
    name                = "k8sbackserver2"
    resource_group_name = azurerm_resource_group.unirRG.name
    location            = azurerm_resource_group.unirRG.location
    size                = var.vm_k8s_back_size
    admin_username      = "adminunir"
    network_interface_ids = [ azurerm_network_interface.k8sBack2NIC.id ]
    disable_password_authentication = true

    admin_ssh_key {
        username   = "adminunir"
        public_key = file(".ssh/id_rsa_azure_unir.pub")
    }

    os_disk {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    plan {
        name      = "centos-8-stream-free"
        product   = "centos-8-stream-free"
        publisher = "cognosys"
    }

    source_image_reference {
        publisher = "cognosys"
        offer     = "centos-8-stream-free"
        sku       = "centos-8-stream-free"
        version   = "1.2019.0810"
    }

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.stAccount.primary_blob_endpoint
    }
	
    tags = {
        environment = "UNIR"
    }

}


