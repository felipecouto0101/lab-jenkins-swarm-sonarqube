#!/bin/bash

# Update system
apt-get update

# Install required packages first
apt-get install -y unzip wget openjdk-17-jdk

# Install PostgreSQL
apt-get install -y postgresql postgresql-contrib

# Configure PostgreSQL
sudo -u postgres psql -c "CREATE USER sonarqube WITH PASSWORD 'sonarpass';"
sudo -u postgres psql -c "CREATE DATABASE sonarqube OWNER sonarqube;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE sonarqube TO sonarqube;"

# Configure PostgreSQL to accept connections
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/12/main/postgresql.conf
echo "host all all 0.0.0.0/0 md5" >> /etc/postgresql/12/main/pg_hba.conf

# Restart PostgreSQL
systemctl restart postgresql
systemctl enable postgresql

# Create sonarqube user
useradd -m -s /bin/bash sonarqube

# Download and install SonarQube
cd /opt
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-10.3.0.82913.zip
unzip sonarqube-10.3.0.82913.zip
mv sonarqube-10.3.0.82913 sonarqube
chown -R sonarqube:sonarqube /opt/sonarqube

# Configure SonarQube
cat > /opt/sonarqube/conf/sonar.properties << EOF
sonar.jdbc.username=sonarqube
sonar.jdbc.password=sonarpass
sonar.jdbc.url=jdbc:postgresql://localhost/sonarqube
sonar.web.host=0.0.0.0
sonar.web.port=9000
EOF

# Configure system limits
echo "sonarqube   -   nofile   131072" >> /etc/security/limits.conf
echo "sonarqube   -   nproc    8192" >> /etc/security/limits.conf
echo "vm.max_map_count=524288" >> /etc/sysctl.conf
echo "fs.file-max=131072" >> /etc/sysctl.conf
sysctl -p

# Create systemd service
cat > /etc/systemd/system/sonarqube.service << EOF
[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=forking
ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
User=sonarqube
Group=sonarqube
Restart=always
LimitNOFILE=131072
LimitNPROC=8192

[Install]
WantedBy=multi-user.target
EOF

# Enable and start SonarQube
systemctl daemon-reload
systemctl enable sonarqube
systemctl start sonarqube

# Wait for SonarQube to start
sleep 30

echo "SonarQube installation completed!"
echo "Access SonarQube at: http://localhost:9000"
echo "Default credentials: admin/admin"
echo "Database: PostgreSQL on port 5432"