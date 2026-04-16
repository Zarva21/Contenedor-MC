#!/bin/bash

set -e

echo "=== CREACIÓN DE CONTENEDOR MINECRAFT ==="

read -p "CT ID: " CTID
read -p "Hostname (ej: mc-server): " HOSTNAME
read -p "IP (ej: 192.168.137.50/24): " IP
read -p "Gateway (ej: 192.168.137.1): " GATEWAY
read -p "RAM (MB): " RAM
read -p "DISK (GB): " DISK

echo "Descargando template Debian..."
pveam update
pveam download local debian-12-standard_*.tar.zst

TEMPLATE=$(ls /var/lib/vz/template/cache/debian-12-standard_*.tar.zst | head -n 1)

echo "Creando contenedor..."

pct create $CTID $TEMPLATE \
  --hostname $HOSTNAME \
  --memory $RAM \
  --cores 2 \
  --rootfs local-lvm:${DISK} \
  --net0 name=eth0,bridge=vmbr0,ip=$IP,gw=$GATEWAY \
  --unprivileged 1 \
  --features nesting=1

echo "Iniciando contenedor..."
pct start $CTID

echo "=== CONTENEDOR LISTO ==="
echo "Entrar con: pct enter $CTID"