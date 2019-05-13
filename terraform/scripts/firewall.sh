#!/bin/sh

DEBIAN_FRONTEND=noninteractive
export DEBIAN_FRONTEND

sudo apt-get install -y ufw

# General rules
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Specific rules
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 1935/tcp

# Engage
sudo ufw enable

# Display rule sets
sudo ufw status
