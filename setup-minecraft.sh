#!/bin/bash

set -e

echo " Actualizando sistema..."
apt update && apt upgrade -y

echo " Instalando Java..."
apt install -y openjdk-21-jre curl wget gnupg

echo "Creando usuario minecraft..."
id minecraft || useradd -m -r -d /home/minecraft -s /bin/bash minecraft



echo " Creando directorio del servidor..."
mkdir -p /home/minecraft/server
chown -R minecraft:minecraft /home/minecraft

sudo -u minecraft bash <<EOF
cd /home/minecraft/server
wget https://piston-data.mojang.com/v1/objects/64bb6d763bed0a9f1d632ec347938594144943ed/server.jar
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
ExecStart=/usr/bin/java -Xms512M -Xmx4G -jar server.jar nogui
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

chown -R minecraft:minecraft /home/minecraft
chmod -R 755 /home/minecraft


echo " Instalando playit..."

curl -SsL https://playit-cloud.github.io/ppa/key.gpg | gpg --dearmor > /etc/apt/trusted.gpg.d/playit.gpg
echo "deb [signed-by=/etc/apt/trusted.gpg.d/playit.gpg] https://playit-cloud.github.io/ppa/data ./" > /etc/apt/sources.list.d/playit-cloud.list
apt update
apt install -y playit



echo " Recargando systemd..."
systemctl daemon-reload

echo " Activando servicios..."
systemctl enable minecraft
systemctl enable playit

echo " Iniciando servicios..."
systemctl start minecraft
systemctl start playit

echo " Instalación completa. ahora tocaria configurar playit para exponer el puerto del servidor de Minecraft."