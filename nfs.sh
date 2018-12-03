#!/bin/bash

source ./datos.cfg
dpkg -s nfs-kernel-server &> /dev/null
if [ $? -eq 1 ]; then
	echo -e "\e[1m\e[31mEl paquete nfs-kernel-server no esta instalado, se dispondra a su instalación\e[0m"
	apt-get install nfs-kernel-server -y >> /dev/null
else
	echo -e "\e[1m\e[32mEl paquete nfs-kernel-server ya esta instalado, se continuara con el script\e[0m"
fi
mv /etc/exports /etc/exports.bak
for carpeta in ${CARPCOMP//,/ }; do
	echo -e "\e[1mCreando y compartiendo /$carpeta\e[0m"
	mkdir  -p /$carpeta
	echo /$carpeta >> /etc/exports
done
systemctl restart nfs-kernel-server
