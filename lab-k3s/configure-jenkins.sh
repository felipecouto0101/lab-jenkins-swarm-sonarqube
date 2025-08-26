#!/bin/bash
# Script para configurar Jenkins para usar K3s

echo "Configurando Jenkins para K3s..."

# Configurar Docker daemon para registry inseguro
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
  "insecure-registries": ["192.168.56.40:5000"]
}
EOF

# Reiniciar Docker
sudo systemctl restart docker

# Configurar SSH para K3s
if [ ! -f ~/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa
fi

# Copiar chave SSH para K3s (usando senha vagrant)
sshpass -p 'vagrant' ssh-copy-id -o StrictHostKeyChecking=no vagrant@192.168.56.40

# Testar conexão SSH
ssh -o StrictHostKeyChecking=no vagrant@192.168.56.40 "echo 'SSH configurado com sucesso'"

echo "Jenkins configurado para K3s!"
echo "Registry: http://192.168.56.40:5000"
echo "SSH: Configurado para vagrant@192.168.56.40"