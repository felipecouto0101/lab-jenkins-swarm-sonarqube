# SonarQube Lab com Vagrant

Este projeto configura automaticamente um servidor SonarQube com PostgreSQL usando Vagrant e VirtualBox.

## 📋 Pré-requisitos

- [Vagrant](https://www.vagrantup.com/downloads) instalado
- [VirtualBox](https://www.virtualbox.org/wiki/Downloads) instalado
- Pelo menos 3GB de RAM disponível
- Conexão com internet

## 🚀 Como usar

### 1. Iniciar o ambiente

```bash
cd lab-sonarqube
vagrant up
```

### 2. Acessar SonarQube

Abra o navegador e acesse: http://localhost:9000

### 3. Login inicial

- **Usuário**: `admin`
- **Senha**: `admin`
- Será solicitado para alterar a senha no primeiro acesso

### 4. Configuração inicial

1. Faça login com as credenciais padrão
2. Altere a senha do administrador
3. Configure seu primeiro projeto

## ⚙️ Configuração da VM

| Componente | Valor |
|------------|-------|
| OS | Ubuntu 20.04 LTS |
| RAM | 3GB |
| CPU | 2 cores |
| IP | 192.168.56.30 |
| Porta SonarQube | 9000 |
| Porta PostgreSQL | 5433 |

## 🛠️ Software instalado

- **Java 17** - Runtime para SonarQube
- **SonarQube 10.3** - Plataforma de análise de código
- **PostgreSQL 12** - Banco de dados
- **Unzip** - Para extrair arquivos

## 🔧 Comandos úteis

```bash
# Status da VM
vagrant status

# SSH na VM
vagrant ssh sonarqube

# Verificar status do SonarQube
vagrant ssh sonarqube -c "sudo systemctl status sonarqube"

# Verificar logs do SonarQube
vagrant ssh sonarqube -c "sudo tail -f /opt/sonarqube/logs/sonar.log"

# Reiniciar SonarQube
vagrant ssh sonarqube -c "sudo systemctl restart sonarqube"

# Verificar PostgreSQL
vagrant ssh sonarqube -c "sudo systemctl status postgresql"

# Parar VM
vagrant halt

# Destruir VM
vagrant destroy -f
```

## 📁 Estrutura do projeto

```
lab-sonarqube/
├── Vagrantfile          # Configuração da VM
├── provision.sh         # Script de instalação
└── README.md           # Este arquivo
```

## 🗄️ Banco de dados

- **PostgreSQL 12** configurado automaticamente
- **Database**: `sonarqube`
- **User**: `sonarqube`
- **Password**: `sonarpass`
- **Port**: `5432`

## 📊 Análise de código

### Exemplo com projeto Java:

```bash
# Instalar SonarScanner
wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.8.0.2856-linux.zip
unzip sonar-scanner-cli-4.8.0.2856-linux.zip
export PATH=$PATH:/path/to/sonar-scanner/bin

# Analisar projeto
sonar-scanner \
  -Dsonar.projectKey=meu-projeto \
  -Dsonar.sources=. \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.login=seu-token
```

## 🛠️ Solução de problemas

### SonarQube não inicia
```bash
# Verificar logs
vagrant ssh sonarqube -c "sudo tail -f /opt/sonarqube/logs/sonar.log"

# Verificar limites do sistema
vagrant ssh sonarqube -c "ulimit -n"
```

### Problemas de memória
```bash
# Verificar uso de memória
vagrant ssh sonarqube -c "free -h"

# Aumentar memória da VM no Vagrantfile se necessário
vb.memory = "4096"
```

### PostgreSQL não conecta
```bash
# Verificar status
vagrant ssh sonarqube -c "sudo systemctl status postgresql"

# Testar conexão
vagrant ssh sonarqube -c "sudo -u postgres psql -c '\l'"
```

### Resetar senha admin
```bash
# Conectar ao PostgreSQL
vagrant ssh sonarqube
sudo -u postgres psql sonarqube

# Resetar senha (dentro do psql)
UPDATE users SET crypted_password='$2a$12$uCkkXmhW5ThVK8mpBvnXOOJRLd64LJeHTeCkSuB3lfaR2N0AYBaSi', salt=null, hash_method='BCRYPT' WHERE login='admin';
```

## 🔐 Tokens de acesso

Para integração com CI/CD:

1. Acesse **Administration > Security > Users**
2. Clique no usuário admin
3. Vá em **Tokens**
4. Gere um novo token
5. Use o token nas integrações

## 📈 Métricas disponíveis

- **Bugs** - Problemas que podem causar comportamento incorreto
- **Vulnerabilities** - Pontos que podem ser explorados por atacantes
- **Code Smells** - Problemas de manutenibilidade
- **Coverage** - Cobertura de testes
- **Duplications** - Código duplicado
- **Complexity** - Complexidade ciclomática