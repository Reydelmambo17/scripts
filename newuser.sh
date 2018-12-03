#!/bin/bash
uid=`cat /etc/passwd | cut -d ":" -f3 | sort -n | tail -2 | head -1`
uid=$((uid + 1))
#read -p "Escribe un nombre de usuario: " usu
cat /etc/passwd | grep $1: >>  /dev/null
if [ $# -eq 0 ]; then
	echo "Faltan parametros"
	exit
else
	if [ $? -eq 0 ]; then
		echo "El usuario $1 ya existe"
	else
		echo "El usuario $1 no existe"
		read -p "Desea crear ese usuario [s/n]: " sn
		if [ $sn = s ]; then
			echo $1:x:$uid:$uid::/home/$1:/bin/bash >> /etc/passwd
			echo $1:x:$uid: >> /etc/group
			passwd $1
			cp -r /etc/skel /home/$1
			chown -R $1:$1 /home/$1
		fi
	fi
fi
