#!/bin/bash

# Install Docker
sudo apt update
sudo apt upgrade -y
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/trusted.gpg.d/docker.asc
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install -y docker-ce
sudo systemctl start docker
sudo systemctl enable docker
sudo docker --version

# Install AWS CLI v2 on Ubuntu/Debian-based EC2 Instances
info "Installing AWS CLI v2..."
sudo apt update
sudo apt install -y unzip curl
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws --version

# Git installation
sudo yum install git -y

sudo docker build -t job-application-app .
sudo docker run -p 8000:8000 job-application-app
sudo aws ecr create-repository --repository-name job-application-app
sudo aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin 148761665406.dkr.ecr.eu-west-2.amazonaws.com
sudo docker tag job-application-app:latest 148761665406.dkr.ecr.eu-west-2.amazonaws.com/job-application-app:latest
sudo docker push 148761665406.dkr.ecr.eu-west-2.amazonaws.com/job-application-app:latest
sudo aws ecs update-service --cluster job-application-cluster --service job-application-service --force-new-deployment
sudo eksctl create cluster --name job-application-cluster --region eu-west-2 --nodes 3
sudo kubectl get nodes
sudo kubectl apply -f deployment.yaml
sudo kubectl apply -f service.yaml
sudo kubectl get pods
sudo kubectl get svc
sudo kubectl get svc job-application-service