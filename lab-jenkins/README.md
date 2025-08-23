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

### 2. Configuração manual (obrigatória)

**Importante**: Jenkins e Docker precisam ser configurados manualmente após o provisionamento.

```bash
vagrant ssh jenkins

# 1. Instalar Jenkins
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install -y jenkins

# 2. Configurar Docker para Jenkins
sudo usermod -aG docker jenkins

# 3. Habilitar e reiniciar Jenkins
sudo systemctl enable jenkins
sudo systemctl restart jenkins

# 4. Verificar configurações
echo "Verificando configurações..."
groups jenkins
sudo systemctl status jenkins
sudo systemctl status nexus

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

### 4. Criar Pipeline Job

1. **Dashboard > New Item**
2. Nome: `meu-pipeline`
3. Tipo: **Pipeline**
4. Clique **OK**

### 5. Configurar Pipeline

#### Opção A - Pipeline script from SCM (Recomendado):
1. **Configure** do seu job
2. **Pipeline > Definition**: `Pipeline script from SCM`
3. **SCM**: `Git`
4. **Repository URL**: URL do seu repositório GitHub
5. **Credentials**: `github-credentials`
6. **Branch**: `*/main`
7. **Script Path**: `Jenkinsfile` (exatamente assim)
8. **Save**

#### Opção B - Pipeline script direto:
1. **Pipeline > Definition**: `Pipeline script`
2. Cole o código do pipeline no campo **Script**
3. **Save**

**Importante**: Para usar a Opção A, seu repositório deve ter um arquivo `Jenkinsfile` na raiz.



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

## 🔗 Integração com Outros Labs

### Plugins necessários para integração completa

Vá em **Manage Jenkins > Manage Plugins > Available** e instale:

#### Para SonarQube:
- SonarQube Scanner
- Quality Gates Plugin

#### Para Nexus:
- Nexus Artifact Uploader
- Pipeline: Maven Integration

#### Para Docker/Swarm:
- Docker Pipeline
- Docker Commons Plugin
- SSH Agent Plugin

### Configurar Tools

Vá em **Manage Jenkins > Global Tool Configuration**:

#### Maven:
- Name: `Maven-3.8`
- Install automatically: ✓
- Version: 3.8.6

#### SonarQube Scanner:
- Name: `SonarQubeScanner` (exatamente assim)
- Install automatically: ✓
- Version: Latest

### Configurar Credenciais

Vá em **Manage Jenkins > Manage Credentials > Global**:

#### Nexus:
- Tipo: **Username with password**
- Username: `admin`
- Password: [senha do Nexus]
- ID: `nexus-credentials`

#### SonarQube:
- Tipo: **Secret text**
- Secret: [token do SonarQube]
- ID: `sonar-token`

#### Docker Swarm SSH:
- Tipo: **SSH Username with private key**
- Username: `vagrant`
- Private Key: [chave SSH do Swarm]
- ID: `swarm-ssh-key`

### Configurar SonarQube Server

Vá em **Manage Jenkins > Configure System > SonarQube servers**:
- Name: `Sonarqube` 
- Server URL: `http://192.168.56.30:9000`
- Server authentication token: `sonar-token`

### Pipeline de integração completa

```groovy
pipeline {
    agent any
    
    tools {
        maven 'Maven-3.8'
    }
    
    environment {
        NEXUS_URL = 'http://192.168.56.20:8081'
        SWARM_MANAGER = '192.168.56.10'
    }
    
    stages {
        stage('Checkout') {
            steps {
                git credentialsId: 'github-credentials',
                    url: 'https://github.com/seu-usuario/seu-repo.git',
                    branch: 'main'
            }
        }
        
        stage('Build & Test') {
            steps {
                sh 'mvn clean package'
            }
        }
        
        stage('SonarQube Analysis') {
            environment {
                SCANNER_HOME = tool 'SonarQubeScanner'
            }
            steps {
                withSonarQubeEnv('Sonarqube') {
                    sh '${SCANNER_HOME}/bin/sonar-scanner'
                }
            }
        }
        
        stage('Quality Gate') {
            steps {
                timeout(time: 1, unit: 'HOURS') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
        
        stage('Deploy to Nexus') {
            steps {
                nexusArtifactUploader(
                    nexusVersion: 'nexus3',
                    protocol: 'http',
                    nexusUrl: '192.168.56.20:8081',
                    groupId: 'com.example',
                    version: '${BUILD_NUMBER}',
                    repository: 'maven-releases',
                    credentialsId: 'nexus-credentials',
                    artifacts: [
                        [artifactId: 'myapp',
                         classifier: '',
                         file: 'target/myapp.jar',
                         type: 'jar']
                    ]
                )
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    def image = docker.build("myapp:${BUILD_NUMBER}")
                }
            }
        }
        
        stage('Deploy to Swarm') {
            steps {
                sshagent(['swarm-ssh-key']) {
                    sh """
                        ssh vagrant@${SWARM_MANAGER} '
                            docker service update --image myapp:${BUILD_NUMBER} myapp ||
                            docker service create --name myapp --replicas 3 -p 8080:8080 myapp:${BUILD_NUMBER}
                        '
                    """
                }
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
    }
}
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

### Problemas com Docker
```bash
# Verificar se jenkins está no grupo docker
vagrant ssh jenkins -c "groups jenkins"
# Deve mostrar: jenkins : jenkins docker

# Se não estiver, adicionar:
vagrant ssh jenkins -c "sudo usermod -aG docker jenkins && sudo systemctl restart jenkins"

# Testar Docker
vagrant ssh jenkins -c "sudo -u jenkins docker run hello-world"
```

### Resetar senhas
```bash
# Jenkins - remover configuração
vagrant ssh jenkins -c "sudo systemctl stop jenkins && sudo rm /var/lib/jenkins/config.xml && sudo systemctl start jenkins"

# Nexus - senha está sempre em:
vagrant ssh jenkins -c "sudo cat /opt/sonatype-work/nexus3/admin.password"
```