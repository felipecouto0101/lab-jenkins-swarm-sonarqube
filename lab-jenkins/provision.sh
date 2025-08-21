#!/bin/bash

# Update system
apt-get update

# Install Java 17 (required by Jenkins)
apt-get install -y openjdk-17-jdk

# Set Java 17 as default
update-alternatives --set java /usr/lib/jvm/java-17-openjdk-amd64/bin/java

# Add Jenkins repository with updated key method
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" > /etc/apt/sources.list.d/jenkins.list

# Update package list
apt-get update

# Install Jenkins
apt-get install -y jenkins

# Start and enable Jenkins
systemctl start jenkins
systemctl enable jenkins

# Install Docker (optional for CI/CD pipelines)
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# Add jenkins user to docker group
usermod -aG docker jenkins

# Install Git
apt-get install -y git

# Install Nexus Repository Manager
echo "Installing Nexus Repository Manager..."
cd /opt
wget https://download.sonatype.com/nexus/3/nexus-3.75.1-01-unix.tar.gz
tar -xzf nexus-3.75.1-01-unix.tar.gz
rm nexus-3.75.1-01-unix.tar.gz
mv nexus-3.75.1-01 nexus

# Create nexus user
useradd -r -d /opt/nexus -s /bin/bash nexus
chown -R nexus:nexus /opt/nexus
chown -R nexus:nexus /opt/sonatype-work

# Configure Nexus to run as nexus user
echo 'run_as_user="nexus"' > /opt/nexus/bin/nexus.rc

# Create systemd service for Nexus
cat > /etc/systemd/system/nexus.service << EOF
[Unit]
Description=nexus service
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
ExecStart=/opt/nexus/bin/nexus start
ExecStop=/opt/nexus/bin/nexus stop
User=nexus
Restart=on-abort
TimeoutSec=600

[Install]
WantedBy=multi-user.target
EOF

# Enable and start Nexus
systemctl daemon-reload
systemctl enable nexus
systemctl start nexus

# Restart Jenkins to apply docker group permissions
systemctl restart jenkins

echo "Jenkins and Nexus installation completed!"
echo "Access Jenkins at: http://localhost:8080"
echo "Access Nexus at: http://localhost:8081"
echo "Initial admin password location: /var/lib/jenkins/secrets/initialAdminPassword"
echo "Nexus admin password location: /opt/sonatype-work/nexus3/admin.password"