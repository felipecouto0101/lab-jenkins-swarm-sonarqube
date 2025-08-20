# Jenkins Lab com Vagrant

Este projeto configura automaticamente um servidor Jenkins usando Vagrant e VirtualBox.

## 📋 Pré-requisitos

- [Vagrant](https://www.vagrantup.com/downloads) instalado
- [VirtualBox](https://www.virtualbox.org/wiki/Downloads) instalado
- Pelo menos 2GB de RAM disponível
- Conexão com internet

## 🚀 Como usar

### 1. Iniciar o ambiente

```bash
cd lab-jenkins
vagrant up
```

### 2. Acessar Jenkins

Abra o navegador e acesse: http://localhost:8080

### 3. Configuração inicial

```bash
# Obter senha inicial do Jenkins
vagrant ssh jenkins
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

### 4. Configurar Jenkins

1. Cole a senha inicial no navegador
2. Instale os plugins sugeridos
3. Crie o usuário administrador
4. Configure a URL do Jenkins

## ⚙️ Configuração da VM

| Componente | Valor |
|------------|-------|
| OS | Ubuntu 20.04 LTS |
| RAM | 2GB |
| CPU | 2 cores |
| IP | 192.168.56.20 |
| Porta Jenkins | 8080 |
| Porta Agents | 50000 |

## 🛠️ Software instalado

- **Java 11** - Runtime para Jenkins
- **Jenkins** - Servidor de CI/CD
- **Docker** - Para pipelines containerizados
- **Git** - Controle de versão

## 🔧 Comandos úteis

```bash
# Status da VM
vagrant status

# SSH na VM
vagrant ssh jenkins

# Reiniciar Jenkins
vagrant ssh jenkins -c "sudo systemctl restart jenkins"

# Ver logs do Jenkins
vagrant ssh jenkins -c "sudo journalctl -u jenkins -f"

# Parar VM
vagrant halt

# Destruir VM
vagrant destroy -f
```

## 📁 Estrutura do projeto

```
lab-jenkins/
├── Vagrantfile          # Configuração da VM
├── provision.sh         # Script de instalação
└── README.md           # Este arquivo
```

## 🐳 Usando Docker no Jenkins

O Docker está instalado e o usuário jenkins foi adicionado ao grupo docker:

```bash
# Testar Docker no Jenkins
vagrant ssh jenkins
sudo -u jenkins docker run hello-world
```

## 🔗 Integração com GitHub

### 1. Instalar plugins necessários

Vá em **Manage Jenkins > Manage Plugins > Available** e instale:

- **GitHub Integration Plugin**
- **GitHub Branch Source Plugin** 
- **Pipeline: GitHub Groovy Libraries**

Ou via CLI:
```bash
vagrant ssh jenkins
sudo -u jenkins java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080/ install-plugin github github-branch-source pipeline-github-lib
```

### 2. Configurar credenciais GitHub

1. Vá em **Manage Jenkins > Manage Credentials**
2. Clique em **Global** > **Add Credentials**
3. Tipo: **Username with password**
   - Username: seu-usuario-github
   - Password: [Personal Access Token]
   - ID: `github-credentials`

### 3. Criar Personal Access Token

1. GitHub > **Settings > Developer settings > Personal access tokens**
2. **Generate new token** com permissões:
   - `repo` (acesso completo aos repositórios)
   - `admin:repo_hook` (webhooks)
   - `user:email` (acesso ao email)

### 4. Configurar Webhook (opcional)

1. No repositório GitHub: **Settings > Webhooks**
2. **Add webhook**:
   - Payload URL: `http://192.168.56.20:8080/github-webhook/`
   - Content type: `application/json`
   - Events: `Just the push event`



### 5. Job Freestyle com GitHub

1. **New Item** > **Freestyle project**
2. **Source Code Management**:
   - Git
   - Repository URL: `https://github.com/seu-usuario/seu-repo.git`
   - Credentials: `github-credentials`
   - Branch: `*/main`
3. **Build Triggers**:
   - GitHub hook trigger for GITScm polling
4. **Build Steps**: Adicione seus comandos

### 6. Multibranch Pipeline

1. **New Item** > **Multibranch Pipeline**
2. **Branch Sources** > **Add source** > **GitHub**
3. Configurar:
   - Credentials: `github-credentials`
   - Repository HTTPS URL: `https://github.com/seu-usuario/seu-repo`
   - Behaviors: Discover branches, Discover pull requests

## 🛠️ Solução de problemas

### Jenkins não inicia
```bash
vagrant ssh jenkins -c "sudo systemctl status jenkins"
```

### Problemas de memória
```bash
# Aumentar heap do Jenkins
vagrant ssh jenkins
sudo nano /etc/default/jenkins
# Adicionar: JAVA_ARGS="-Xmx1024m"
sudo systemctl restart jenkins
```

### Resetar senha admin
```bash
vagrant ssh jenkins
sudo systemctl stop jenkins
sudo rm /var/lib/jenkins/config.xml
sudo systemctl start jenkins
```

### Problemas com GitHub
```bash
# Testar conectividade
vagrant ssh jenkins
curl -I https://api.github.com

# Verificar credenciais
# Vá em Manage Jenkins > Manage Credentials > Test Connection
```