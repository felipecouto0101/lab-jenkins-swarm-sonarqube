# DevOps Labs com Vagrant

Este projeto contém 3 laboratórios práticos de DevOps usando Vagrant e VirtualBox para criar ambientes isolados e reproduzíveis.

## 🎯 Objetivo

Fornecer ambientes de desenvolvimento e aprendizado para ferramentas essenciais de DevOps, permitindo experimentação sem impactar o sistema host.

## 📋 Pré-requisitos

- [Vagrant](https://www.vagrantup.com/downloads) instalado
- [VirtualBox](https://www.virtualbox.org/wiki/Downloads) instalado
- Pelo menos 8GB de RAM disponível (para executar todos os labs)
- Conexão com internet

## 🧪 Laboratórios Disponíveis

### 1. 🔧 Jenkins Lab
**Localização**: `lab-jenkins/`

Servidor Jenkins completo para CI/CD com:
- Jenkins + Java 17
- Docker integrado
- Git configurado
- Integração com GitHub

**Acesso**: http://localhost:8080  
**Recursos**: 2GB RAM, 2 CPUs

### 2. 📊 SonarQube Lab
**Localização**: `lab-sonarqube/`

Plataforma de análise de código com:
- SonarQube 10.3
- PostgreSQL 12
- Java 17
- Integração com Jenkins

**Acesso**: http://localhost:9000  
**Recursos**: 3GB RAM, 2 CPUs

### 3. 🐳 Docker Swarm Lab
**Localização**: `lab-swarm/`

Cluster Docker Swarm com:
- 1 Manager node
- 2 Worker nodes
- Docker Engine
- Swarm mode configurado

**Recursos**: 1GB RAM por node (3GB total)

## 🚀 Início Rápido

### Executar um laboratório específico:
```bash
# Jenkins
cd lab-jenkins && vagrant up

# SonarQube
cd lab-sonarqube && vagrant up

# Docker Swarm
cd lab-swarm && vagrant up
```

### Executar todos os laboratórios:
```bash
# Em terminais separados
cd lab-jenkins && vagrant up &
cd lab-sonarqube && vagrant up &
cd lab-swarm && vagrant up &
```

## 🔗 Integrações

### Jenkins + SonarQube
- Configure SonarQube server no Jenkins: `http://192.168.56.30:9000`
- Use tokens de autenticação para integração
- Pipelines com Quality Gates automáticos

### Jenkins + GitHub
- Webhooks para builds automáticos
- Multibranch pipelines
- Pull request validation

### Jenkins + Docker Swarm
- Deploy automático via pipelines
- Orquestração de containers
- Scaling automático

## 📁 Estrutura do Projeto

```
lab-devOps-2/
├── README.md                    # Este arquivo
├── lab-jenkins/                 # Laboratório Jenkins
│   ├── Vagrantfile
│   ├── provision.sh
│   └── README.md
├── lab-sonarqube/              # Laboratório SonarQube
│   ├── Vagrantfile
│   ├── provision.sh
│   ├── docker-compose.yml
│   └── README.md
└── lab-swarm/                  # Laboratório Docker Swarm
    ├── Vagrantfile
    ├── provision.sh
    └── README.md
```

## 🌐 Rede e Portas

| Serviço | IP | Porta | Acesso |
|---------|----|----|--------|
| Jenkins | 192.168.56.20 | 8080 | http://localhost:8080 |
| SonarQube | 192.168.56.30 | 9000 | http://localhost:9000 |
| Swarm Manager | 192.168.56.10 | - | SSH only |
| Swarm Worker 1 | 192.168.56.11 | - | SSH only |
| Swarm Worker 2 | 192.168.56.12 | - | SSH only |

## 🔧 Comandos Úteis

```bash
# Status de todos os labs
vagrant global-status

# Parar todos os labs
cd lab-jenkins && vagrant halt
cd lab-sonarqube && vagrant halt
cd lab-swarm && vagrant halt

# Destruir todos os labs
cd lab-jenkins && vagrant destroy -f
cd lab-sonarqube && vagrant destroy -f
cd lab-swarm && vagrant destroy -f

# SSH em qualquer VM
vagrant ssh <vm-name>
```

## 🛠️ Solução de Problemas

### Problemas de memória
- Certifique-se de ter pelo menos 8GB RAM
- Execute apenas os labs necessários
- Ajuste a memória no Vagrantfile se necessário

### Conflitos de porta
- Verifique se as portas 8080 e 9000 estão livres
- Modifique o port forwarding no Vagrantfile se necessário

### Problemas de rede
- Verifique se a rede 192.168.56.0/24 está disponível
- Desabilite outros adaptadores de rede virtual se necessário

## 📚 Documentação

Cada laboratório possui sua própria documentação detalhada:
- [Jenkins Lab](lab-jenkins/README.md)
- [SonarQube Lab](lab-sonarqube/README.md)
- [Docker Swarm Lab](lab-swarm/README.md)

