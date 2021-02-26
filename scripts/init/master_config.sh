#!/bin/bash


#########################################################################
#                                                                       #
# Script de la configuración inicial del servidor Master (Master K8S)   #
#                                                                       #
# - Sincronización NTP                                                  #
# - Instalación Ansible                                                 #
# - Instalación paquetes NFS                                            #
#                                                                       #
#########################################################################

# Asinando nombre al servidor Master.
echo 'Hostname master.devops.unir' >> master_deployment.log 2>&1
sudo hostnamectl set-hostname master.devopsunir.com

# Sicronización NTP
sudo timedatectl set-timezone Europe/Madrid
sudo dnf install chrony -y
sudo systemctl enable chronyd
sudo systemctl start chronyd
sudo timedatectl set-ntp true
sudo dnf install nfs-utils nfs4-acl-tools wget -y

# Instalación Ansible.
echo 'Instalando dependencias en nodo Master...' >> master_deployment.log 2>&1
sudo dnf install -y epel-release >> master_deployment.log 2>&1
sudo dnf install -y python3 >> master_deployment.log 2>&1
sudo dnf makecache >> master_deployment.log 2>&1
sudo dnf install -y ansible >> master_deployment.log 2>&1
sudo dnf install -y git >> master_deployment.log 2>&1

# Montando servidor NFS
sudo pvcreate /dev/sdc
sudo vgcreate data_vg /dev/sdc
sudo lvcreate -n nfs_lv /dev/data_vg -l100%FREE
sudo mkfs.xfs /dev/data_vg/nfs_lv
sudo mkdir /srv/nfs
sudo -- sh -c "echo '/dev/data_vg/nfs_lv        /srv/nfs                xfs     defaults        0 0' >> /etc/fstab"
sudo mount -a
sudo dnf install nfs-utils net-tools -y

sudo -- sh -c "echo '/srv/nfs  10.1.1.4(rw,sync)' >> /etc/exports"
sudo -- sh -c "echo '/srv/nfs  10.1.1.5(rw,sync)' >> /etc/exports"
sudo -- sh -c "echo '/srv/nfs  10.1.1.6(rw,sync)' >> /etc/exports"

sudo exportfs -r
sudo exportfs -s

sudo systemctl start nfs-server.service
sudo systemctl enable nfs-server.service
