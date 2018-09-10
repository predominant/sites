#!/bin/sh

DEBIAN_FRONTEND=noninteractive
export DEBIAN_FRONTEND

# Update Ubuntu
sudo apt-get -y update
sudo apt-get -y upgrade

# Install Habitat
curl "https://raw.githubusercontent.com/habitat-sh/habitat/master/components/hab/install.sh" | sudo bash

hab pkg install core/cacerts
hab pkg install core/hab-sup

# Install Habitat service
mkdir -p /etc/systemd/system

cat <<EOT > /etc/systemd/system/hab-sup.service
[Unit]
Description=Habitat Supervisor
[Service]
ExecStartPre=/bin/bash -c "/bin/systemctl set-environment SSL_CERT_FILE=$(hab pkg path core/cacerts)/ssl/cert.pem"
ExecStart=/bin/hab run --auto-update
[Install]
WantedBy=default.target
EOT

systemctl daemon-reload
systemctl start hab-sup

# Wait for the sup to come up before proceeding.
until hab svc status > /dev/null 2>&1; do
  sleep 1
done

hab svc load \
  grahamweldon/site-grahamweldon \
  --strategy at-once
