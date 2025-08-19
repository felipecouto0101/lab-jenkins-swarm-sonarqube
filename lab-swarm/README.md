# Docker Swarm Cluster com Vagrant

Este projeto configura automaticamente um cluster Docker Swarm com 3 VMs usando Vagrant e VirtualBox.

## 📋 Pré-requisitos

- [Vagrant](https://www.vagrantup.com/downloads) instalado
- [VirtualBox](https://www.virtualbox.org/wiki/Downloads) instalado
- Pelo menos 4GB de RAM disponível
- Conexão com internet para download das imagens

## 🏗️ Arquitetura

```
┌─────────────────────────────────────────────────────────────┐
│                    Docker Swarm Cluster                    │
├─────────────────┬─────────────────┬─────────────────────────┤
│    Manager      │    Worker1      │       Worker2           │
│  192.168.56.10  │  192.168.56.11  │    192.168.56.12        │
│   Port: 8090    │   Port: 8091    │     Port: 8092          │
│   (Leader)      │                 │                         │
└─────────────────┴─────────────────┴─────────────────────────┘
```

## 🚀 Como usar

### 1. Clonar e iniciar o ambiente

```bash
git clone <seu-repositorio>
cd lab-devOps-2/lab-swarm
vagrant up
```

### 2. Verificar status das VMs

```bash
vagrant status
```

### 3. Configurar Docker Swarm (Manual)

O Docker é instalado automaticamente, mas o cluster Swarm deve ser configurado manualmente:

```bash
# 1. Inicializar Swarm no manager
vagrant ssh manager
sudo docker swarm init --advertise-addr 192.168.56.10

# 2. Copiar o comando join-token que aparece na saída
# Exemplo: docker swarm join --token SWMTKN-1-xxx... 192.168.56.10:2377

# 3. Conectar worker1 ao cluster
vagrant ssh worker1
sudo docker swarm join --token <TOKEN> 192.168.56.10:2377

# 4. Conectar worker2 ao cluster
vagrant ssh worker2
sudo docker swarm join --token <TOKEN> 192.168.56.10:2377

# 5. Verificar nodes do cluster
vagrant ssh manager
sudo docker node ls
```

### 4. Deployar um serviço de exemplo

```bash
# Criar serviço nginx com 3 réplicas
vagrant ssh manager
sudo docker service create --name web --replicas 3 -p 80:80 nginx

# Verificar serviços
sudo docker service ls

# Ver onde as réplicas estão rodando
sudo docker service ps web
```

### 5. Testar o acesso

Abra o navegador e acesse:
- http://localhost:8090 (manager)
- http://localhost:8091 (worker1)
- http://localhost:8092 (worker2)

## 📁 Estrutura do projeto

```
lab-devOps-2/
└── lab-swarm/
    ├── Vagrantfile          # Configuração das VMs
    ├── provision.sh         # Script de instalação do Docker
    └── README.md           # Este arquivo
```

## ⚙️ Configuração das VMs

| VM      | IP            | Porta Host | Função  |
|---------|---------------|------------|---------|
| manager | 192.168.56.10 | 8090       | Leader  |
| worker1 | 192.168.56.11 | 8091       | Worker  |
| worker2 | 192.168.56.12 | 8092       | Worker  |

## 🐳 Comandos Docker Swarm úteis

```bash
# Listar nodes
sudo docker node ls

# Listar serviços
sudo docker service ls

# Escalar serviço
sudo docker service scale web=5

# Ver logs do serviço
sudo docker service logs web

# Remover serviço
sudo docker service rm web

# Inspecionar serviço
sudo docker service inspect web
```

## 🔧 Comandos Vagrant úteis

```bash
# Iniciar todas as VMs
vagrant up

# Parar todas as VMs
vagrant halt

# Reiniciar todas as VMs
vagrant reload

# Destruir todas as VMs
vagrant destroy -f

# SSH em uma VM específica
vagrant ssh manager
vagrant ssh worker1
vagrant ssh worker2

# Status das VMs
vagrant status
```

## 🛠️ Solução de problemas

### VMs não iniciam
```bash
# Verificar se VirtualBox está funcionando
VBoxManage --version

# Reiniciar VMs
vagrant reload
```

### Problemas de rede
```bash
# Verificar conectividade entre VMs
vagrant ssh manager -c "ping -c 3 192.168.56.11"
```

### Docker não funciona
```bash
# Verificar status do Docker
vagrant ssh manager -c "sudo systemctl status docker"

# Reiniciar Docker
vagrant ssh manager -c "sudo systemctl restart docker"
```

### Workers não conectam ao Swarm
```bash
# 1. Verificar se o manager está ativo
vagrant ssh manager -c "sudo docker info | grep Swarm"

# 2. Gerar novo token se necessário
vagrant ssh manager -c "sudo docker swarm join-token worker"

# 3. Sair do swarm no worker e tentar novamente
vagrant ssh worker1 -c "sudo docker swarm leave --force"
vagrant ssh worker1 -c "sudo docker swarm join --token <TOKEN> 192.168.56.10:2377"

# 4. Verificar conectividade de rede
vagrant ssh worker1 -c "ping -c 3 192.168.56.10"
```

## 📊 Recursos utilizados

- **Sistema Operacional**: Ubuntu 20.04 LTS
- **Docker**: 28.1.1
- **Rede**: 192.168.56.0/24 (host-only)
- **RAM por VM**: ~1GB
- **Disco por VM**: ~40GB


## 📝 Notas importantes

- As VMs são criadas com IPs fixos na rede 192.168.56.0/24
- O Docker é instalado automaticamente, mas o Swarm deve ser configurado manualmente
- Cada VM tem acesso à internet via NAT
- Os arquivos do projeto são sincronizados em `/vagrant` dentro das VMs
- O plugin vagrant-vbguest é desabilitado para evitar conflitos
