#!/bin/bash

# Atualizar sistema
apt-get update

# Instalar Docker
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Adicionar usuário vagrant ao grupo docker
usermod -aG docker vagrant

# Iniciar Docker
systemctl start docker
systemctl enable docker

# Copiar configuração do Prometheus
cp /vagrant/prometheus.yml /home/vagrant/prometheus.yml
chown vagrant:vagrant /home/vagrant/prometheus.yml

# Instalar Node Exporter
docker run -d \
  --name node-exporter \
  --restart unless-stopped \
  -p 9100:9100 \
  -v "/proc:/host/proc:ro" \
  -v "/sys:/host/sys:ro" \
  -v "/:/rootfs:ro" \
  --pid="host" \
  prom/node-exporter:latest \
  --path.procfs=/host/proc \
  --path.rootfs=/rootfs \
  --path.sysfs=/host/sys \
  --collector.filesystem.mount-points-exclude='^/(sys|proc|dev|host|etc)($$|/)'

# Aguardar Node Exporter inicializar
sleep 10

# Instalar Prometheus
docker run -d \
  --name prometheus \
  --restart unless-stopped \
  -p 9090:9090 \
  -v /home/vagrant/prometheus.yml:/etc/prometheus/prometheus.yml \
  prom/prometheus:latest \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/prometheus \
  --web.console.libraries=/etc/prometheus/console_libraries \
  --web.console.templates=/etc/prometheus/consoles \
  --web.enable-lifecycle

# Instalar pacotes para teste de stress
apt-get install -y stress stress-ng htop

# Instalar Grafana
docker run -d \
  --name grafana \
  --restart unless-stopped \
  -p 3000:3000 \
  -e GF_SECURITY_ADMIN_PASSWORD=admin \
  -v grafana-storage:/var/lib/grafana \
  grafana/grafana:latest

# Aguardar Grafana inicializar
sleep 30

# Configurar datasource Prometheus
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Prometheus",
    "type": "prometheus",
    "url": "http://192.168.56.50:9090",
    "access": "proxy",
    "isDefault": true
  }' \
  http://admin:admin@localhost:3000/api/datasources

# Criar script de teste de stress
cat > /home/vagrant/stress_test.sh << 'EOF'
#!/bin/bash
echo "Iniciando teste de stress..."
echo "CPU stress por 60 segundos:"
stress --cpu 2 --timeout 60s &
echo "Memory stress por 60 segundos:"
stress --vm 1 --vm-bytes 512M --timeout 60s &
echo "Disk I/O stress por 60 segundos:"
stress --io 1 --timeout 60s &
echo "Aguarde 60 segundos e verifique o dashboard Grafana"
wait
echo "Teste de stress concluído!"
EOF

chmod +x /home/vagrant/stress_test.sh
chown vagrant:vagrant /home/vagrant/stress_test.sh

echo "=== LAB PROMETHEUS + GRAFANA INSTALADO ==="
echo "Prometheus: http://localhost:9090"
echo "Grafana: http://localhost:3000 (admin/admin)"
echo "Node Exporter: http://localhost:9100"
echo ""
echo "Para executar teste de stress:"
echo "vagrant ssh -c './stress_test.sh'"
echo ""
echo "Importe dashboard Node Exporter ID: 1860"