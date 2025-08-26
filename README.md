# DevOps Labs com Vagrant

Este projeto contém 4 laboratórios práticos de DevOps usando Vagrant e VirtualBox para criar ambientes isolados e reproduzíveis com pipeline CI/CD completo.

## 🎯 Objetivo

Fornecer ambientes de desenvolvimento e aprendizado para ferramentas essenciais de DevOps, permitindo experimentação sem impactar o sistema host.

## 📋 Pré-requisitos

- [Vagrant](https://www.vagrantup.com/downloads) instalado
- [VirtualBox](https://www.virtualbox.org/wiki/Downloads) instalado
- Pelo menos 10GB de RAM disponível (para executar todos os labs)
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

### 4. ☸️ K3s Lab
**Localização**: `lab-k3s/`

Cluster Kubernetes lightweight com:
- K3s (Kubernetes)
- Docker Registry integrado
- Configuração para registries inseguros
- Deploy automático via Jenkins

**Acesso**: http://localhost:8084 (apps), Registry: http://localhost:5000  
**Recursos**: 2GB RAM, 2 CPUs

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
cd lab-k3s && vagrant up &
```

## 🔗 Integrações e Pipeline CI/CD

### Pipeline Completo: Jenkins → SonarQube → Nexus → K3s
O projeto implementa um pipeline DevOps completo:

1. **Build & Test** - Compilação e testes Java
2. **SonarQube Analysis** - Análise de qualidade de código
3. **Quality Gate** - Portão de qualidade automático
4. **Nexus Repository** - Armazenamento de artefatos
5. **Docker Build & Push** - Construção e envio de imagens
6. **K3s Deploy** - Deploy automático no Kubernetes

### Comunicação entre Labs

#### Jenkins (192.168.56.20) se comunica com:
- **SonarQube** (192.168.56.30:9000) - Análise de código
- **Nexus** (192.168.56.20:8081) - Upload de artefatos
- **K3s** (192.168.56.40:6443) - Deploy Kubernetes
- **Docker Registry** (192.168.56.40:5000) - Push de imagens

#### Fluxo de Dados:
```
Jenkins → SonarQube (análise)
   ↓
Nexus (artefatos) → Docker Registry (imagens)
   ↓
K3s (deploy final)
```

### Configurações de Rede
Todos os labs estão na mesma rede privada `192.168.56.0/24` permitindo comunicação direta entre os serviços.


## 🌐 Rede e Portas

| Serviço | IP | Porta | Acesso |
|---------|----|----|--------|
| Jenkins | 192.168.56.20 | 8080 | http://localhost:8080 |
| Nexus | 192.168.56.20 | 8081 | http://localhost:8081 |
| SonarQube | 192.168.56.30 | 9000 | http://localhost:9000 |
| K3s Master | 192.168.56.40 | 6443 | Kubernetes API |
| Docker Registry | 192.168.56.40 | 5000 | http://localhost:5000 |
| K3s Apps | 192.168.56.40 | 80 | http://localhost:8084 |
| Swarm Manager | 192.168.56.10 | - | SSH only |
| Swarm Worker 1 | 192.168.56.11 | - | SSH only |
| Swarm Worker 2 | 192.168.56.12 | - | SSH only |


## 📚 Documentação

Cada laboratório possui sua própria documentação detalhada:
- [Jenkins Lab](lab-jenkins/README.md)
- [SonarQube Lab](lab-sonarqube/README.md)
- [Docker Swarm Lab](lab-swarm/README.md)
- [K3s Lab](lab-k3s/README.md)


