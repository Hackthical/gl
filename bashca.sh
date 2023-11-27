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
