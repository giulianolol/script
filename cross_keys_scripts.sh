#!/bin/bash
sudo apt-get install sshpass
# Variables de configuración
VM1_IP="192.168.56.4"     # IP de la primera máquina virtual
VM2_IP="192.168.56.5"     # IP de la segunda máquina virtual
VM_USER="vagrant"         # Usuario en ambas VMs
VM_PASS="vagrant"         # Contraseña de las VMs

# Generar la clave SSH en la VM si no existe
generar_clave_ssh() {
    local ip=$1
    sshpass -p "$VM_PASS" ssh -o StrictHostKeyChecking=no $VM_USER@$ip "if [ ! -f ~/.ssh/id_rsa ]; then ssh-keygen -t rsa -f ~/.ssh/id_rsa -N ''; fi"
}

# Copiar clave pública de una VM a la otra
copiar_clave() {
    local from_ip=$1
    local to_ip=$2

    # Obtener la clave pública desde la VM origen
    clave_pub=$(sshpass -p "$VM_PASS" ssh -o StrictHostKeyChecking=no $VM_USER@$from_ip "cat ~/.ssh/id_rsa.pub" | tr -d '\r')

    # Añadir la clave pública en la VM destino
    sshpass -p "$VM_PASS" ssh -o StrictHostKeyChecking=no $VM_USER@$to_ip "echo '$clave_pub' >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
}

# Generar claves SSH si no existen
echo "Generando claves SSH en $VM1_IP y $VM2_IP si no existen..."
generar_clave_ssh $VM1_IP
generar_clave_ssh $VM2_IP

# Cruzar las claves SSH
echo "Cruzando claves SSH entre $VM1_IP y $VM2_IP..."
copiar_clave $VM1_IP $VM2_IP
copiar_clave $VM2_IP $VM1_IP
