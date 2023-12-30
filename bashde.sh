#!/bin/bash
sudo apt update
sudo apt install -y docker.io docker-compose python3-pip iptraf iperf openvpn net-tools snmpd speedtest-cli nano cron
crontab -l | { cat; echo "5 1   *   *   *    /sbin/shutdown -r +10"; } | crontab -
sudo timedatectl set-timezone "Europe/Berlin"
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
    environment:
      TZ : "Europe/Berlin"
      USER_ID : "1001"
    volumes:
      - "/docker/appdata/firefox-hadi:/config:rw"
    restart: always
  squid:
    image: cooolin/socks5
    container_name: socks5
    ports:
      - "12334:1080"
    environment:
      - PROXY_HOST=0.0.0.0
      - PROXY_PORT=1080
    restart: always
EOF
sudo docker-compose up -d
