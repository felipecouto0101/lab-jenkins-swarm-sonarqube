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