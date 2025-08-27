# 🐳 K3s Lab

Laboratório K3s (Kubernetes leve) com Docker Registry integrado para CI/CD.

## 🎯 Objetivo

Fornecer cluster Kubernetes leve para deploy de aplicações via pipeline Jenkins com registry privado.

## 📋 Pré-requisitos

- [Vagrant](https://www.vagrantup.com/downloads) instalado
- [VirtualBox](https://www.virtualbox.org/wiki/Downloads) instalado
- 2GB RAM disponível
- Labs Jenkins e SonarQube rodando

## 🚀 Início Rápido

```bash
cd lab-k3s
vagrant up
```

## 🔧 Configuração

### VM Specs
- **OS**: Ubuntu 20.04
- **RAM**: 2GB
- **CPU**: 2 cores
- **IP**: 192.168.56.40

### Serviços Instalados
- **K3s**: Kubernetes leve
- **Docker Registry**: Registry privado na porta 5000
- **kubectl**: Cliente Kubernetes configurado

## 🌐 Portas e Acessos

| Serviço | Porta | Acesso |
|---------|-------|--------|
| K3s API | 6443 | kubectl |
| Registry | 5000 | http://localhost:5000 |
| Apps | 8084 | http://localhost:8084 |

## 🔗 Integração com Pipeline

### 1. Instalar Plugins no Jenkins
1. Acesse: http://localhost:8080
2. **Manage Jenkins** → **Plugins** → **Available**
3. Busque e instale:
   - **Kubernetes plugin**
   - **Kubernetes CLI plugin**
4. **Restart Jenkins**

### 2. Instalar kubectl no Jenkins
```bash
# Acessar Jenkins VM
cd ../lab-jenkins && vagrant ssh

# Instalar kubectl
curl -LO https://dl.k8s.io/release/v1.28.0/bin/linux/amd64/kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Verificar instalação
kubectl version --client
```

### 3. Configurar Credenciais K3s
1. **Manage Jenkins** → **Credentials** → **System** → **Global credentials**
2. **Add Credentials** → **Secret file**
3. **ID**: `k3s`
4. **Description**: `K3s kubeconfig`
5. **File**: Upload o arquivo `kubeconfig` do diretório lab-k3s
6. **Save**

**⚠️ IMPORTANTE**: Se você recriou o cluster K3s, deve atualizar as credenciais:
- O arquivo `kubeconfig` é gerado automaticamente durante o provisionamento
- Sempre use o arquivo mais recente após `vagrant up`
- Atualize as credenciais no Jenkins se houver problemas de conectividade

### 4. Configurar Kubernetes Cloud
1. **Manage Jenkins** → **Clouds** → **Add Cloud** → **Kubernetes**
2. **Name**: `k3s`
3. **Kubernetes URL**: `https://192.168.56.40:6443`
4. **Disable https certificate check**: ✓ (para lab)
5. **Test Connection** → Should work
6. **Save**



### 5. Configurar Docker Registry
```bash
# Acessar Jenkins VM
cd ../lab-jenkins && vagrant ssh

# Configurar Docker registry inseguro
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
  "insecure-registries": ["192.168.56.40:5000"]
}
EOF
sudo systemctl restart docker
```


## 🛠️ Comandos Úteis

```bash
# Status do cluster
vagrant ssh -c "kubectl get nodes"

# Verificar registry
curl http://localhost:5000/v2/_catalog

# Logs dos pods
vagrant ssh -c "kubectl logs -l app=jenkins-java-app"

# Acessar VM
vagrant ssh

# Parar lab
vagrant halt

# Destruir lab
vagrant destroy -f
```

## 🔄 Fluxo CI/CD Completo

```
Jenkins → SonarQube → Nexus → Registry K3s → Deploy K3s
```

1. **Build & Test**: Código compilado e testado
2. **SonarQube**: Análise de qualidade
3. **Nexus**: Artefatos JAR armazenados
4. **Registry**: Imagem Docker enviada para registry K3s
5. **Deploy**: Aplicação implantada no cluster K3s

## 🌐 Topologia de Rede

```
Jenkins (192.168.56.20) ──┐
SonarQube (192.168.56.30) ─┼─→ K3s (192.168.56.40)
Nexus (192.168.56.20)     ─┘    ├── Registry :5000
                                 └── Apps :8084
```

## 🛠️ Solução de Problemas

### Registry não acessível
```bash
# Verificar se registry está rodando
vagrant ssh -c "kubectl get pods | grep registry"

# Testar conectividade
curl -v http://192.168.56.40:5000/v2/
```

### Deploy falha
```bash
# Verificar logs
vagrant ssh -c "kubectl describe pods -l app=jenkins-java-app"
vagrant ssh -c "kubectl logs -l app=jenkins-java-app"
```

### SSH não funciona
```bash
# Reconfigurar chaves SSH
ssh-keygen -f ~/.ssh/known_hosts -R 192.168.56.40
ssh-copy-id vagrant@192.168.56.40
```