#!/bin/bash


#########################################################################
#                                                                       #
# Script de la configuración inicial del servidor Back2 (Worker K8S)    #
#                                                                       #
# - Sincronización NTP                                                  #
# - Instalación Ansible                                                 #
# - Instalación paquetes NFS                                            #
#                                                                       #
#########################################################################

# Asinando nombre al servidor back2.
echo 'Hostname back2.devops.unir' >> back2_deployment.log 2>&1
sudo hostnamectl set-hostname back2.devopsunir.com

# Sicronización NTP
sudo timedatectl set-timezone Europe/Madrid
sudo dnf install chrony -y
sudo systemctl enable chronyd
sudo systemctl start chronyd
sudo timedatectl set-ntp true
sudo dnf install nfs-utils nfs4-acl-tools wget -y

# Instalación Ansible.
echo 'Instalando dependencias en Back2...' >> back2_deployment.log 2>&1
sudo dnf install -y epel-release >> back2_deployment.log 2>&1
sudo dnf install -y python3 >> back2_deployment.log 2>&1
sudo dnf makecache >> back2_deployment.log 2>&1
sudo dnf install -y ansible >> back2_deployment.log 2>&1
sudo dnf install -y git >> back2_deployment.log 2>&1

sudo dnf install nfs-utils nfs4-acl-tools net-tools -y