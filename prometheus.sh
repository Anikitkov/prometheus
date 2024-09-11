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
sudo chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus
sudo cp /tmp/prometheus*/promtool /usr/local/bin/
sudo cp /tmp/prometheus*/prometheus /usr/local/bin/
sudo cp -r /tmp/prometheus*/console_libraries  /etc/prometheus/
sudo cp  /tmp/prometheus*/prometheus.yml  /etc/prometheus/
sudo chown prometheus:prometheus /usr/local/bin/{prometheus,promtool}
sudo touch /etc/systemd/system/prometheus.service 
sudo chmod 777 /etc/systemd/system/prometheus.service

sudo cat > /etc/systemd/system/prometheus.service <<EOF
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
  
#install alertmanager
sudo mkdir -p /etc/alertmanager /var/lib/prometheus/alertmanager
sudo cp /tmp/alertmanager*/alertmanager /usr/local/bin/
sudo cp /tmp/alertmanager*/amtool /usr/local/bin/
sudo cp /tmp/alertmanager*/alertmanager.yml  /etc/alertmanager/
sudo useradd --no-create-home --shell /bin/false alertmanager
sudo chown -R alertmanager:alertmanager /etc/alertmanager /var/lib/prometheus/alertmanager
sudo chown alertmanager:alertmanager /usr/local/bin/{alertmanager,amtool}
sudo touch /etc/systemd/system/alertmanager.service
sudo chmod 777 /etc/systemd/system/alertmanager.service
sudo cat > /etc/systemd/system/alertmanager.service <<EOF
^[[200~[Unit]
Description=Alertmanager Service
After=network.target

[Service]
EnvironmentFile=-/etc/default/alertmanager
User=alertmanager
Group=alertmanager
Type=simple
ExecStart=/usr/local/bin/alertmanager           --config.file=/etc/alertmanager/alertmanager.yml           --storage.path=/var/lib/prometheus/alertmanager           --cluster.advertise-address=0.0.0.0:9093           $ALERTMANAGER_OPTS
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl enable alertmanager
sudo systemctl start alertmanager

#install node-exporter



                          
#install node-exporter
sudo cp /tmp/node_exporter*/node_exporter /usr/local/bin/
sudo useradd --no-create-home --shell /bin/false nodeexporter
sudo chown -R nodeexporter:nodeexporter /usr/local/bin/node_exporter
sudo touch /etc/systemd/system/node_exporter.service
sudo chmod 777 /etc/systemd/system/node_exporter.service
sudo cat > /etc/systemd/system/node_exporter.service <<EOF
> [Unit]
Description=Node Exporter Service
After=network.target

[Service]
User=nodeexporter
Group=nodeexporter
Type=simple
ExecStart=/usr/local/bin/node_exporter
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
sudo cat >> /etc/prometheus/prometheus.yml <<EOF
scrape_configs:
  ...
  - job_name: 'node_exporter_clients'
    scrape_interval: 5s
    static_configs:
      - targets:
          - 127.0.0.1:9100
EOF

sudo systemctl enable node_exporter
sudo systemctl start node_exporter


sudo systemctl enable prometheus
sudo systemctl start prometheus





















