#!/bin/bash

set -e

echo " Actualizando sistema..."
apt update && apt upgrade -y

echo " Instalando Java..."
apt install -y openjdk-17-jre curl wget gnupg

echo " Creando usuario minecraft..."
useradd -m -r -d /home/minecraft -s /bin/bash minecraft || true

echo " Creando directorio del servidor..."
mkdir -p /home/minecraft/server
chown -R minecraft:minecraft /home/minecraft

echo "⬇ Descargando servidor Minecraft..."
sudo -u minecraft bash <<EOF
cd /home/minecraft/server
wget -O server.jar https://piston-data.mojang.com/v1/objects/fe3b6c2c4bdfaf3d4f8f4cdb5c7c7e5e6e6e6e6e/server.jar || true
echo "eula=true" > eula.txt
EOF

echo " Creando servicio systemd para Minecraft..."

cat <<EOF > /etc/systemd/system/minecraft.service
[Unit]
Description=Minecraft Server
After=network.target

[Service]
User=minecraft
WorkingDirectory=/home/minecraft/server
ExecStart=/usr/bin/java -Xms1G -Xmx2G -jar server.jar nogui
Restart=always

[Install]
WantedBy=multi-user.target
EOF

echo " Instalando playit..."

curl -SsL https://playit-cloud.github.io/ppa/key.gpg | gpg --dearmor > /etc/apt/trusted.gpg.d/playit.gpg
echo "deb [signed-by=/etc/apt/trusted.gpg.d/playit.gpg] https://playit-cloud.github.io/ppa/data ./" > /etc/apt/sources.list.d/playit-cloud.list
apt update
apt install -y playit

echo " Creando servicio systemd para playit..."

cat <<EOF > /etc/systemd/system/playit.service
[Unit]
Description=Playit Tunnel Agent
After=network.target

[Service]
ExecStart=/usr/bin/playit
Restart=always

[Install]
WantedBy=multi-user.target
EOF

echo " Recargando systemd..."
systemctl daemon-reload

echo " Activando servicios..."
systemctl enable minecraft
systemctl enable playit

echo " Iniciando servicios..."
systemctl start minecraft
systemctl start playit

echo " Instalación completa."