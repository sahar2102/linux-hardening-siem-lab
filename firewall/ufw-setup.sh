#!/usr/bin/env bash
# UFW firewall policy for the hardened Ubuntu server.
# Default deny inbound, allow outbound; only SSH (port 2102) from trusted hosts.
set -euo pipefail

TRUSTED_HOSTS=("192.168.56.105")   # Kali VM, also used as the admin client in the lab
SSH_PORT=2102

ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw logging medium

# SSH only from trusted IPs, with rate limiting (max 6 connections / 30 s)
for ip in "${TRUSTED_HOSTS[@]}"; do
  ufw limit from "$ip" to any port "$SSH_PORT" proto tcp
done

# Web traffic if a web service is hosted
ufw allow 80/tcp
ufw allow 443/tcp

# Explicitly refuse insecure legacy services
ufw deny 21     # FTP
ufw deny 23     # Telnet

# Block ping: in /etc/ufw/before.rules change the INPUT echo-request rule
#   -A ufw-before-input -p icmp --icmp-type echo-request -j ACCEPT
# to DROP (a DROP rule added after the ACCEPT line never matches).
sed -i 's/-A ufw-before-input -p icmp --icmp-type echo-request -j ACCEPT/-A ufw-before-input -p icmp --icmp-type echo-request -j DROP/' /etc/ufw/before.rules

ufw --force enable
ufw status verbose
