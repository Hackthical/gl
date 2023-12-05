#!/bin/bash
DEBIAN_FRONTEND=noninteractive
sudo apt update
sudo apt install -y docker.io docker-compose python3-pip iptraf iperf openvpn net-tools snmpd speedtest-cli nano
sudo timedatectl set-timezone "America/Montreal"
sudo echo "rocommunity [Gr00pL@nc!ng]" > /etc/snmp/snmpd.conf
sudo echo "view systemview included .1.3." >> /etc/snmp/snmpd.conf
systemctl restart snmpd
cat <<EOF > ./docker-compose.yml
version: "3.9"
services:
  3x-ui:
    image: ghcr.io/mhsanaei/3x-ui:latest
    container_name: 3x-ui
    hostname: yourhostname
    ports:
      - "7070:2053/tcp"
      - "8443:8443/tcp"
      - "443:443/tcp"
    volumes:
      - /home/ubuntu/db/:/etc/x-ui/
      - /home/ubuntu/cert/:/root/cert/
    environment:
      XRAY_VMESS_AEAD_FORCED: "false"
    extra_hosts:
      - "host.docker.internal:host-gateway"
    restart: always
  firefox:
    image: jlesage/firefox
    container_name: firefox
    ports:
      - "900:5900"
      - "800:5800"
    environment:
      TZ : "America/Montreal"
      USER_ID : "1001"
    volumes:
      - "/docker/appdata/firefox-hadi:/config:rw"
    restart: always
EOF
sudo docker-compose up -d
sudo ufw default allow routed
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow from 5.75.196.198 to any port 22
sudo ufw allow from 142.132.177.45 to any port 22
sudo ufw allow from 142.132.163.34 to any port 22
sudo ufw allow from 91.107.147.249 to any port 22
sudo ufw allow from 167.235.158.128 to any port 22
sudo ufw allow from 5.75.196.198 to any port 7070
sudo ufw allow from 142.132.177.45 to any port 7070
sudo ufw allow from 142.132.163.34 to any port 7070
sudo ufw allow from 91.107.147.249 to any port 7070
sudo ufw allow from 167.235.158.128 to any port 7070
sudo ufw allow from 154.90.54.213 to any port 900
sudo ufw allow from 95.217.37.174 to any port 900
sudo ufw allow from any to any port 443
ufw deny out from any to 10.0.0.0/8
ufw deny out from any to 172.16.0.0/12
ufw deny out from any to 192.168.0.0/16
ufw deny out from any to 141.101.78.0/23
ufw deny out from any to 173.245.48.0/20
sudo ufw enable
