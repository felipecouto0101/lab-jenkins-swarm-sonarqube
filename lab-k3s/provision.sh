#!/bin/bash

# Atualizar sistema
apt-get update

# Configurar registries inseguros para K3s
mkdir -p /etc/rancher/k3s
cat > /etc/rancher/k3s/registries.yaml <<EOF
mirrors:
  "192.168.56.40:5000":
    endpoint:
      - "http://192.168.56.40:5000"
configs:
  "192.168.56.40:5000":
    tls:
      insecure_skip_verify: true
EOF

# Instalar K3s com IP específico
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--tls-san 192.168.56.40 --bind-address 192.168.56.40 --advertise-address 192.168.56.40" sh -

# Aguardar K3s inicializar
sleep 30

# Instalar Docker Registry
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: docker-registry
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: docker-registry
  template:
    metadata:
      labels:
        app: docker-registry
    spec:
      containers:
      - name: registry
        image: registry:2
        ports:
        - containerPort: 5000
        env:
        - name: REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY
          value: /var/lib/registry
        volumeMounts:
        - name: registry-storage
          mountPath: /var/lib/registry
      volumes:
      - name: registry-storage
        hostPath:
          path: /opt/registry
          type: DirectoryOrCreate
---
apiVersion: v1
kind: Service
metadata:
  name: docker-registry
  namespace: default
spec:
  selector:
    app: docker-registry
  ports:
  - port: 5000
    targetPort: 5000
  type: LoadBalancer
EOF

# Configurar kubectl para usuário vagrant
mkdir -p /home/vagrant/.kube
cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
chown vagrant:vagrant /home/vagrant/.kube/config
chmod 600 /home/vagrant/.kube/config

# Adicionar alias kubectl para vagrant
echo 'alias k=kubectl' >> /home/vagrant/.bashrc

# Configurar Docker daemon para registry inseguro
mkdir -p /etc/docker
cat > /etc/docker/daemon.json <<EOF
{
  "insecure-registries": ["192.168.56.40:5000", "localhost:5000"]
}
EOF

# Instalar Docker para push de imagens
apt-get install -y docker.io
systemctl restart docker
usermod -aG docker vagrant

# Configurar acesso externo ao cluster
sed -i 's/127.0.0.1/192.168.56.40/g' /etc/rancher/k3s/k3s.yaml
# Criar diretório se não existir
mkdir -p /vagrant
cp /etc/rancher/k3s/k3s.yaml /vagrant/kubeconfig
chmod 644 /vagrant/kubeconfig

# Aguardar registry estar pronto
echo "Aguardando registry inicializar..."
sleep 60
kubectl wait --for=condition=available --timeout=300s deployment/docker-registry

# Configurar SSH para Jenkins
echo "vagrant ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl restart sshd

# Gerar chave SSH se não existir
if [ ! -f /home/vagrant/.ssh/id_rsa ]; then
    sudo -u vagrant ssh-keygen -t rsa -N '' -f /home/vagrant/.ssh/id_rsa
fi

# Adicionar chave pública ao authorized_keys
sudo -u vagrant cat /home/vagrant/.ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys
chmod 600 /home/vagrant/.ssh/authorized_keys
chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys

echo "K3s e Registry instalados com sucesso!"
echo "Registry: http://192.168.56.40:5000"
echo "SSH configurado para Jenkins"
echo "Kubeconfig disponível em: /vagrant/kubeconfig"
echo "Acesse: kubectl get nodes"