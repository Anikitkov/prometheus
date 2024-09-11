#!/bin/bash
sudo wget https://github.com/prometheus/prometheus/releases/download/v2.54.1/prometheus-2.54.1.linux-amd64.tar.gz -P /tmp
sudo wget https://github.com/prometheus/alertmanager/releases/download/v0.27.0/alertmanager-0.27.0.linux-amd64.tar.gz -P /tmp
sudo wget https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-amd64.tar.gz -P /tmp
sudo tar -xvzf /tmp/prometheus*.tar.gz -C /tmp/
sudo tar -xvzf /tmp/alertmanager*.tar.gz -C /tmp/
sudo tar -xvzf /tmp/node_exporter*.tar.gz -C /tmp/
sudo useradd --no-create-home --shell /bin/false prometheus
sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus
chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus
sudo cp /tmp/prometheus*/promtool /usr/local/bin/
sudo cp /tmp/prometheus*/prometheus /usr/local/bin/
sudo cp -r /tmp/prometheus*/console_libraries  /etc/prometheus/
sudo cp  /tmp/prometheus*/prometheus.yml  /etc/prometheus/
sudo chown prometheus:prometheus /usr/local/bin/{prometheus,promtool}
sudo cat >> /etc/systemd/system/prometheus.service <<EOF
[Unit]
Description=Prometheus Service
Documentation=https://prometheus.io/docs/introduction/overview/
After=network.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
 --config.file /etc/prometheus/prometheus.yml \
 --storage.tsdb.path /var/lib/prometheus/ \
 --web.console.templates=/etc/prometheus/consoles \
 --web.console.libraries=/etc/prometheus/console_libraries
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure

 [Install]
 WantedBy=multi-user.target
 EOF
promtool check config /etc/prometheus/prometheus.yml
systemctl enable prometheus
systemctl start prometheus
                          
#install alertmanager
























