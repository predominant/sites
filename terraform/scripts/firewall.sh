#!/bin/sh

DEBIAN_FRONTEND=noninteractive
export DEBIAN_FRONTEND

sudo apt-get install -y ufw

# General rules
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Specific rules
sudo ufw allow 22/tcp # SSH
sudo ufw allow 80/tcp # HTTP
sudo ufw allow 443/tcp # HTTPS
sudo ufw allow 1935/tcp # RTMP
sudo ufw allow 9000/tcp # Minio

# Engage
sudo ufw enable

# Display rule sets
sudo ufw status
