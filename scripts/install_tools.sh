#!/usr/bin/env bash
# One-shot installer for the Lab 1 toolchain on Ubuntu 24.04 LTS:
# Git, Java 21, Jenkins, VS Code, curl. Run with: bash scripts/install_tools.sh
set -euo pipefail

echo "== Updating package index"
sudo apt update

echo "== Installing Git, curl, Python 3 and Java 21 (required by Jenkins)"
sudo apt install -y git curl python3 fontconfig openjdk-21-jre

echo "== Adding the Jenkins LTS apt repository"
sudo install -d -m 0755 /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
    https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" \
    | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

echo "== Installing Jenkins"
sudo apt update
sudo apt install -y jenkins
sudo systemctl enable --now jenkins

echo "== Installing Visual Studio Code"
sudo snap install code --classic

echo "== Versions"
git --version
java -version
python3 --version
jenkins --version || true
code --version | head -n 1

echo
echo "Jenkins is running at http://localhost:8080"
echo "Initial admin password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
