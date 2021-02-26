#!/bin/bash

#########################################################################
#                                                                       #
# Script encargado de la inicialización del entorno K8S                 #
#                                                                       #
#########################################################################

# Accedemos al directorio contenedor de los scripts a ejecutar.
echo 'Lanzando despliegues de Ansible...' >> /home/adminunir/master_deployment.log
cd /home/adminunir/DevOpsUnir/Ansible

# Ejecutando script Ansible de prerequitios e instalación Docker en todos los nodos.
echo 'Lanzando playbook de pre-requisitos...' >> /home/adminunir/master_deployment.log
ansible-playbook playbooks/prerequisites.yml

# Ejecutando script Ansible para la configuración común a todos los nodos.
# - Añade repositorio de K8S
# - Instala paquetes kubelet kubeadm kubectl e inicia kubelet
echo 'Instalando nodos...' >> /home/adminunir/master_deployment.log
ansible-playbook playbooks/setting_up_nodes.yml

# Ejecutando script Ansible para la configuración del nodo Master.
# - Añade reglas al firewall.
# - Instala CNI y Calico
echo 'Configurando Master...' >> /home/adminunir/master_deployment.log
ansible-playbook playbooks/configure_master_node.yml

# Ejecutando script Ansible para la configuración de los nodos "Workers".
# - Añade reglas al firewall.
# - Une los nodos del cluster.
echo 'Configurando Workers...' >> /home/adminunir/master_deployment.log
ansible-playbook playbooks/configure_worker_nodes.yml

# Ejecutando script Ansible para la instalación del Ingress Controller.
echo 'Desplegando Ingress...' >> /home/adminunir/master_deployment.log
ansible-playbook playbooks/setting_up_ingress.yml

# Ejecutando script Ansible que despliega la aplicación en el cluster K8S.
echo 'Desplegando aplicación...' >> /home/adminunir/master_deployment.log
ansible-playbook playbooks/deploy-app.yml

# Test deshabilitando firewalls.
echo 'Deshabilitando firewalls...' >> /home/adminunir/master_deployment.log
ansible-playbook playbooks/disable-firewall.yml