#!/bin/bash

#########################################################################
#                                                                       #
# Script de la configuración y despliegue de elementos comunes en       #
# todos los nodos de la red.                                            #
#                                                                       #
# Script nexo entre el despliegue de la infraestructura desde local y   #
# la distribución y ejecución de scripts de Ansible y K8S para la       #
# instalación de la plataforma.                                         #
#                                                                       #
#########################################################################

# Asinando nombre al servidor bastión.
echo 'Hostname bastion.devops.unir' >> bastion_deployment.log
sudo hostnamectl set-hostname bastion.devopsunir.com

# Configurando zona horaria.
sudo timedatectl set-timezone Europe/Madrid
sudo dnf install chrony -y
sudo systemctl enable chronyd
sudo systemctl start chronyd
sudo timedatectl set-ntp true

# Desplegando archivos con origen GitHub y subidos desde el equipo local.
mkdir /home/adminunir/DevOpsUnir
tar -xzf DevOpsUnir.tar.gz -C /home/adminunir/DevOpsUnir
# Creando privilegios de ejecución a los archivos de shell script.
find /home/adminunir/DevOpsUnir -type f -name "*.sh" -exec chmod -x {} \;

# Asignando valores de IP y nombre de todos los servidores al archivo /etc/hosts
sudo -- sh -c "echo '10.1.4.4 bastion.devopsunir.com' >> /etc/hosts"
sudo -- sh -c "echo '10.1.1.4 master.devopsunir.com' >> /etc/hosts"
sudo -- sh -c "echo '10.1.1.5 back1.devopsunir.com' >> /etc/hosts"
sudo -- sh -c "echo '10.1.1.6 back2.devopsunir.com' >> /etc/hosts"
sudo -- sh -c "echo '10.1.1.4 nfs.devopsunir.com' >> /etc/hosts"

# Replicando claves de acceso a todos los nodos para permitir la acceso ssh para la ejecución de scripts.
echo 'Replicando pk a nodos...' >> bastion_deployment.log
scp -o 'StrictHostKeyChecking no' -i /home/adminunir/.ssh/id_rsa_azure_unir /home/adminunir/.ssh/id_rsa_azure_unir adminunir@master.devopsunir.com:/home/adminunir/.ssh/ >> bastion_deployment.log 2>&1
scp -o 'StrictHostKeyChecking no' -i /home/adminunir/.ssh/id_rsa_azure_unir /home/adminunir/.ssh/id_rsa_azure_unir adminunir@back1.devopsunir.com:/home/adminunir/.ssh/ >> bastion_deployment.log 2>&1
scp -o 'StrictHostKeyChecking no' -i /home/adminunir/.ssh/id_rsa_azure_unir /home/adminunir/.ssh/id_rsa_azure_unir adminunir@back2.devopsunir.com:/home/adminunir/.ssh/ >> bastion_deployment.log 2>&1

# Desplegando archivos para la instalación desantendida a cada uno de los servidores.
echo 'Replicando recursos a nodos...' >> bastion_deployment.log
scp -o 'StrictHostKeyChecking no' -i /home/adminunir/.ssh/id_rsa_azure_unir -r /home/adminunir/DevOpsUnir adminunir@master.devopsunir.com:/home/adminunir/ >> bastion_deployment.log 2>&1
scp -o 'StrictHostKeyChecking no' -i /home/adminunir/.ssh/id_rsa_azure_unir -r /home/adminunir/DevOpsUnir adminunir@back1.devopsunir.com:/home/adminunir/ >> bastion_deployment.log 2>&1
scp -o 'StrictHostKeyChecking no' -i /home/adminunir/.ssh/id_rsa_azure_unir -r /home/adminunir/DevOpsUnir adminunir@back2.devopsunir.com:/home/adminunir/ >> bastion_deployment.log 2>&1

# Ejecutando scripts de configuración de entorno para cada uno de los servidores.
echo 'Ejecutando scripts en remoto para...' >> bastion_deployment.log
echo '--- Nodo Master...' >> bastion_deployment.log
ssh -o 'StrictHostKeyChecking no' -i .ssh/id_rsa_azure_unir adminunir@master.devopsunir.com 'chmod +x /home/adminunir/DevOpsUnir/scripts/init/master_config.sh && /home/adminunir/DevOpsUnir/scripts/init/master_config.sh' >> bastion_deployment.log 2>&1
echo '--- Nodo Back1...' >> bastion_deployment.log
ssh -o 'StrictHostKeyChecking no' -i .ssh/id_rsa_azure_unir adminunir@back1.devopsunir.com 'chmod +x /home/adminunir/DevOpsUnir/scripts/init/back1_config.sh && /home/adminunir/DevOpsUnir/scripts/init/back1_config.sh' >> bastion_deployment.log 2>&1
echo '--- Nodo Back2...' >> bastion_deployment.log
ssh -o 'StrictHostKeyChecking no' -i .ssh/id_rsa_azure_unir adminunir@back2.devopsunir.com 'chmod +x /home/adminunir/DevOpsUnir/scripts/init/back2_config.sh && /home/adminunir/DevOpsUnir/scripts/init/back2_config.sh' >> bastion_deployment.log 2>&1

# Ejecutando scripts Ansible para la configuración y despliegues de K8S.
echo 'Ejecutando Ansible playbooks...' >> bastion_deployment.log
echo '--- Nodo Master...' >> bastion_deployment.log
ssh -o 'StrictHostKeyChecking no' -i .ssh/id_rsa_azure_unir adminunir@master.devopsunir.com 'chmod +x /home/adminunir/DevOpsUnir/scripts/init/master_k8s_init.sh && /home/adminunir/DevOpsUnir/scripts/init/master_k8s_init.sh' >> bastion_deployment.log 2>&1

