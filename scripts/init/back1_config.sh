#!/bin/bash

#########################################################################
#                                                                       #
# Script de la configuración inicial del servidor Back1 (Worker K8S)    #
#                                                                       #
# - Sincronización NTP                                                  #
# - Instalación Ansible                                                 #
# - Instalación paquetes NFS                                            #
#                                                                       #
#########################################################################

# Asinando nombre al servidor back1.
echo 'Hostname back1.devops.unir' >> back1_deployment.log 2>&1
sudo hostnamectl set-hostname back1.devopsunir.com

# Sicronización NTP
sudo timedatectl set-timezone Europe/Madrid
sudo dnf install chrony -y
sudo systemctl enable chronyd
sudo systemctl start chronyd
sudo timedatectl set-ntp true
sudo dnf install nfs-utils nfs4-acl-tools wget -y

# Instalación Ansible.
echo 'Instalando dependencias en Back1...'>> back1_deployment.log 2>&1
sudo dnf install -y epel-release >> back1_deployment.log 2>&1
sudo dnf install -y python3 >> back1_deployment.log 2>&1
sudo dnf makecache >> back1_deployment.log 2>&1
sudo dnf install -y ansible >> back1_deployment.log 2>&1
sudo dnf install -y git >> back1_deployment.log 2>&1

sudo dnf install nfs-utils nfs4-acl-tools net-tools -y
