# Jenkins + Nexus Lab com Vagrant

Este projeto configura um ambiente completo com Jenkins e Nexus Repository Manager usando Vagrant e VirtualBox.

## 📋 Pré-requisitos

- [Vagrant](https://www.vagrantup.com/downloads) instalado
- [VirtualBox](https://www.virtualbox.org/wiki/Downloads) instalado
- Pelo menos 4GB de RAM disponível
- Conexão com internet

## 🚀 Início Rápido

### 1. Iniciar a máquina virtual

```bash
cd lab-jenkins
vagrant up
```

### 2. Instalar Jenkins (obrigatório)

**Importante**: O Jenkins precisa ser instalado manualmente após o provisionamento.

```bash
vagrant ssh jenkins

# Adicionar chave e repositório Jenkins
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# Instalar Jenkins
sudo apt-get update
sudo apt-get install -y jenkins

# Iniciar Jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins

exit
```

### 3. Acessar os serviços

- **Jenkins**: http://localhost:8080
- **Nexus**: http://localhost:8081

### 4. Obter senhas iniciais

```bash
# Senha do Jenkins
vagrant ssh jenkins -c "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"

# Senha do Nexus
vagrant ssh jenkins -c "sudo cat /opt/sonatype-work/nexus3/admin.password"
```

### 5. Configuração inicial

#### Jenkins:
1. Acesse http://localhost:8080
2. Cole a senha inicial
3. Instale os plugins sugeridos
4. Crie o usuário administrador

#### Nexus:
1. Acesse http://localhost:8081
2. Login: `admin` / senha do arquivo admin.password
3. Altere a senha quando solicitado

## ⚙️ Especificações da VM

| Componente | Valor |
|------------|-------|
| OS | Ubuntu 20.04 LTS |
| RAM | 4GB |
| CPU | 2 cores |
| IP | 192.168.56.20 |
| Jenkins | Porta 8080 |
| Nexus | Porta 8081 |

## 🛠️ Software Instalado

- **Java 17** - Runtime para Jenkins e Nexus
- **Jenkins** - Servidor de CI/CD (instalação manual)
- **Nexus 3.75.1** - Gerenciador de artefatos (automático)
- **Docker** - Para pipelines containerizados
- **Git** - Controle de versão

## 🔗 Integração com GitHub

### 1. Instalar plugins no Jenkins

Vá em **Manage Jenkins > Manage Plugins > Available**:
- GitHub Integration Plugin
- GitHub Branch Source Plugin
- Pipeline: GitHub Groovy Libraries


### 2. Personal Access Token

No GitHub: **Settings > Developer settings > Personal access tokens**
- Permissões: `repo`, `admin:repo_hook`, `user:email`


### 3. Configurar credenciais

1. **Manage Jenkins > Manage Credentials > Global > Add Credentials**
2. Tipo: **Username with password**
   - Username: seu-usuario-github
   - Password: [Personal Access Token do GitHub]
   - ID: `github-credentials`


## 📦 Nexus Repository Manager

### Repositórios padrão:
- **maven-central** - Proxy do Maven Central
- **maven-releases** - Releases
- **maven-snapshots** - Snapshots
- **maven-public** - Grupo agregado

### Configuração Maven:
```xml
<!-- settings.xml -->
<mirrors>
  <mirror>
    <id>nexus</id>
    <mirrorOf>*</mirrorOf>
    <url>http://192.168.56.20:8081/repository/maven-public/</url>
  </mirror>
</mirrors>
```

## 🔧 Comandos Úteis

```bash
# Status da VM
vagrant status

# SSH na VM
vagrant ssh jenkins

# Verificar serviços
vagrant ssh jenkins -c "sudo systemctl status jenkins"
vagrant ssh jenkins -c "sudo systemctl status nexus"

# Reiniciar serviços
vagrant ssh jenkins -c "sudo systemctl restart jenkins"
vagrant ssh jenkins -c "sudo systemctl restart nexus"

# Parar/Destruir VM
vagrant halt
vagrant destroy -f
```

## 🛠️ Solução de Problemas

### Jenkins não responde
```bash
# Verificar status
vagrant ssh jenkins -c "sudo systemctl status jenkins"

# Ver logs
vagrant ssh jenkins -c "sudo journalctl -u jenkins -f"

# Reinstalar se necessário
vagrant ssh jenkins -c "sudo apt-get install --reinstall jenkins"
```

### Nexus não responde
```bash
# Verificar status
vagrant ssh jenkins -c "sudo systemctl status nexus"

# Ver logs
vagrant ssh jenkins -c "sudo tail -f /opt/sonatype-work/nexus3/log/nexus.log"

# Verificar memória (Nexus precisa de pelo menos 2GB)
vagrant ssh jenkins -c "free -h"
```

### Problemas de memória
```bash
# Verificar uso atual
vagrant ssh jenkins -c "free -h"

# Se necessário, aumente a memória no Vagrantfile:
# vb.memory = "6144"  # 6GB
```

### Resetar senhas
```bash
# Jenkins - remover configuração
vagrant ssh jenkins -c "sudo systemctl stop jenkins && sudo rm /var/lib/jenkins/config.xml && sudo systemctl start jenkins"

# Nexus - senha está sempre em:
vagrant ssh jenkins -c "sudo cat /opt/sonatype-work/nexus3/admin.password"
```