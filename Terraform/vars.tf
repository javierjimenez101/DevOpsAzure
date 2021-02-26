# Variable que contiene la localización de recursos a desplegar en Azure.
variable "location" {
	type = string
	description = "Región de Azure donde crearemos la infraestructura"
	default = "West Europe"
}

# Variable con las características de la VM del nodo Master.
variable "vm_k8s_master_size" {
	type = string
	description = "Tamaño de la máquina virtual para la instancia Master de k8s"
	default = "Standard_A2_v2" # 4 GB, 2 CPU 
}

# Variable con las características de las VM's de los nodos Worker.
variable "vm_k8s_back_size" {
	type = string
	description = "Tamaño de la máquina virtual para las instancias Nodos de k8s"
	default = "Standard_B1ms" # 2 GB, 1 CPU 
}

# Variable con las características de la VM del bastión.
variable "vm_bastion_size" {
	type = string
	description = "Tamaño de la máquina virtual para la instancia bastión"
	default = "Standard_A1_v2" # 2 GB, 1 CPU 
}
