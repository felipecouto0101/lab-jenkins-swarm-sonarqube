# 📊 Prometheus + Grafana Lab

Laboratório completo de monitoramento com Prometheus, Grafana e Node Exporter.

## 🎯 Objetivo

Fornecer sistema de monitoramento completo com Prometheus, Grafana e Node Exporter para coleta e visualização de métricas do servidor Linux.

## 📋 Pré-requisitos

- [Vagrant](https://www.vagrantup.com/downloads) instalado
- [VirtualBox](https://www.virtualbox.org/wiki/Downloads) instalado
- 2GB RAM disponível

## 🚀 Início Rápido

```bash
cd lab-prometheus
vagrant up
```

## 🔧 Configuração

### VM Specs
- **OS**: Ubuntu 20.04
- **RAM**: 2GB
- **CPU**: 2 cores
- **IP**: 192.168.56.50

### Serviços Instalados
- **Prometheus**: Sistema de monitoramento
- **Grafana**: Visualização de métricas e dashboards
- **Node Exporter**: Coleta métricas do sistema Linux
- **Docker**: Containerização dos serviços
- **Stress Tools**: Ferramentas para teste de carga

## 🌐 Portas e Acessos

| Serviço | Porta | Acesso |
|---------|-------|--------|
| Prometheus | 9090 | http://localhost:9090 |
| Grafana | 3000 | http://localhost:3000 |
| Node Exporter | 9100 | http://localhost:9100 |

## 🔑 Credenciais

- **Grafana**: admin/admin (configurado automaticamente)

## 📊 Configuração Grafana

### 1. Acesso Inicial
1. Acesse: http://localhost:3000
2. Login: **admin/admin**
3. Datasource Prometheus já configurado automaticamente

### 2. Importar Dashboard Node Exporter
1. **+** → **Import**
2. **Dashboard ID**: **1860**
3. **Load** → Selecione datasource **Prometheus**
4. **Import**

### 3. Dashboards Adicionais
- **Site oficial**: https://grafana.com/grafana/dashboards/
- Busque por "Node Exporter", "Prometheus", "Linux" para mais opções
- IDs populares: 1860, 405, 11074, 12486

### 3. Executar Teste de Stress
```bash
vagrant ssh -c "./stress_test.sh"
```

### 4. Validar Métricas
- Verifique picos de CPU, Memory e I/O no dashboard
- Métricas são coletadas a cada 15 segundos
- Dashboard atualiza a cada 5 segundos

## 📊 Métricas Coletadas

### Node Exporter (Sistema Linux)
- **CPU**: Uso, load average, cores
- **Memória**: RAM, swap, buffers
- **Disco**: Espaço, I/O, inodes
- **Rede**: Tráfego, pacotes, erros
- **Sistema**: Uptime, processos, file descriptors

## 🔍 Queries Úteis

### CPU
```promql
# Uso de CPU por core
100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Load average
node_load1
```

### Memória
```promql
# Uso de memória
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100

# Memória livre
node_memory_MemFree_bytes
```

### Disco
```promql
# Espaço em disco usado
100 - ((node_filesystem_avail_bytes * 100) / node_filesystem_size_bytes)

# I/O de disco
rate(node_disk_io_time_seconds_total[5m])
```

## 🛠️ Comandos Úteis

```bash
# Status dos containers
vagrant ssh -c "docker ps"

# Logs do Grafana
vagrant ssh -c "docker logs grafana"

# Logs do Prometheus
vagrant ssh -c "docker logs prometheus"

# Logs do Node Exporter
vagrant ssh -c "docker logs node-exporter"

# Teste de stress manual
vagrant ssh -c "stress --cpu 2 --vm 1 --vm-bytes 256M --timeout 30s"

# Acessar VM
vagrant ssh

# Parar lab
vagrant halt

# Destruir lab
vagrant destroy -f
```

## 🌐 Integração com outros Labs

### Monitorar Jenkins
Adicione ao `prometheus.yml`:
```yaml
  - job_name: 'jenkins'
    static_configs:
      - targets: ['192.168.56.20:8080']
```

### Monitorar SonarQube
```yaml
  - job_name: 'sonarqube'
    static_configs:
      - targets: ['192.168.56.30:9000']
```

### Monitorar K3s
```yaml
  - job_name: 'k3s'
    static_configs:
      - targets: ['192.168.56.40:6443']
```

## 🛠️ Solução de Problemas

### Grafana não acessível
```bash
# Verificar se está rodando
vagrant ssh -c "docker ps | grep grafana"

# Verificar logs
vagrant ssh -c "docker logs grafana"

# Reiniciar container
vagrant ssh -c "docker restart grafana"
```

### Dashboard não mostra dados
```bash
# Verificar datasource
curl http://admin:admin@localhost:3000/api/datasources

# Testar query Prometheus
curl "http://localhost:9090/api/v1/query?query=up"
```

### Teste de stress não funciona
```bash
# Verificar se stress está instalado
vagrant ssh -c "which stress"

# Executar stress manual
vagrant ssh -c "stress --cpu 1 --timeout 10s"
```