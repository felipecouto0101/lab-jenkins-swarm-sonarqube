#!/bin/bash

# Update system
apt-get update

# Install Java 17 (required by Jenkins)
apt-get install -y openjdk-17-jdk

# Set Java 17 as default
update-alternatives --set java /usr/lib/jvm/java-17-openjdk-amd64/bin/java

# Add Jenkins repository
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | apt-key add -
echo "deb https://pkg.jenkins.io/debian-stable binary/" > /etc/apt/sources.list.d/jenkins.list

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

# Add jenkins user to docker group
usermod -aG docker jenkins

# Install Git
apt-get install -y git

echo "Jenkins installation completed!"
echo "Access Jenkins at: http://localhost:8080"
echo "Initial admin password location: /var/lib/jenkins/secrets/initialAdminPassword"