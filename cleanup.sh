#!/bin/bash

echo "Verificando permissões..."
if [ "$EUID" -ne 0 ]; then
  echo "Por favor, execute como superusuário (sudo)."
  exit 1
fi

echo "Parando todos os contêineres..."
sudo docker ps -q | xargs -r sudo docker stop

echo "Removendo todos os contêineres..."
sudo docker ps -a -q | xargs -r sudo docker rm

echo "Removendo as imagens especificadas..."
sudo docker rmi bsb-rfid-smartlocker-app -f
sudo docker rmi postgres:14 -f

echo "Removendo volumes órfãos..."
sudo docker volume prune -f

echo "Removendo redes não utilizadas..."
sudo docker network prune -f

echo "Limpando dados desnecessários..."
sudo docker system prune -f

echo "Tudo limpo!"
