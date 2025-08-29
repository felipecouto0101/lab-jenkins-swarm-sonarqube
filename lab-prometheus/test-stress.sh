#!/bin/bash

echo "=== TESTE DE STRESS PROMETHEUS + GRAFANA ==="
echo ""

# Verificar se os serviços estão rodando
echo "1. Verificando serviços..."
curl -s http://localhost:9090/-/healthy > /dev/null && echo "✅ Prometheus OK" || echo "❌ Prometheus FALHOU"
curl -s http://localhost:3000/api/health > /dev/null && echo "✅ Grafana OK" || echo "❌ Grafana FALHOU"
curl -s http://localhost:9100/metrics > /dev/null && echo "✅ Node Exporter OK" || echo "❌ Node Exporter FALHOU"

echo ""
echo "2. Executando teste de stress..."
echo "   - CPU: 2 cores por 60s"
echo "   - Memory: 512MB por 60s" 
echo "   - Disk I/O: 1 worker por 60s"
echo ""

# Executar stress test
stress --cpu 2 --vm 1 --vm-bytes 512M --io 1 --timeout 60s &
STRESS_PID=$!

echo "3. Monitorando métricas..."
for i in {1..12}; do
    echo "   Tempo: ${i}0s - Verifique Grafana: http://localhost:3000"
    sleep 5
done

wait $STRESS_PID
echo ""
echo "✅ Teste de stress concluído!"
echo ""
echo "4. Validação:"
echo "   - Acesse Grafana: http://localhost:3000 (admin/admin)"
echo "   - Importe dashboard Node Exporter ID: 1860"
echo "   - Verifique picos de CPU, Memory e I/O nos últimos 5 minutos"