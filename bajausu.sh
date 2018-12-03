#!/bin/bash
read -p "Escriba un nombre de usuario: " usu
cat /etc/passwd | grep $usu: >> /dev/null
if [ $? -eq 1 ]; then
	echo "El usuario $usu no existe"
else
	echo "El usuario $usu ya existe"
	read -p "Desea eliminar ese usuario [s/n]: " sn
	if [ $sn = s ]; then
		sed -i "/$usu:/d" /etc/passwd
		sed -i "/$usu:/d" /etc/group
		sed -i "/$usu:/d" /etc/shadow
		rm -rf /home/$usu
	fi
fi
