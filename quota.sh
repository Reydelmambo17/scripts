#!/bin/bash
source ./datos.cfg

cat /etc/fstab | grep usrquota >> /dev/null
if [ $? -eq 1 ]; then
	sed -ie 's:\(.*\)\s\(/\)\s\s*\(\w*\)\s*\(\w*\)\s*\(.*\):\1 \2 \3 \4,usrquota \5:' /etc/fstab
	mount -o remount /
fi

dpkg -s quota &> /dev/null
if [ $? -eq 1 ]; then
	echo -e "\e[1m\e[31mEl paquete quota no esta instalado, se dispondra a su instalación\e[0m"
	apt-get install qouta -y >> /dev/null
else
	echo -e "\e[1m\e[32mEl paquete quota ya esta instalado, se continuara con el script\e[0m"
fi

quotacheck -cum / &> /dev/null
quotaon / &> /dev/null
read -p $'\e[1m¿A que usuario desea añadir quota?: \e[0m' USUARIOQUOTA
read -p $'\e[1m¿Es usuario VIP? [s/n]: \e[0m' VIPQ
if [ $VIPQ = s ]; then
	setquota -u $USUARIOQUOTA $QUOTAVIP $QUOTAVIP 0 0 /
else
	setquota -u $USUARIOQUOTA $QUOTANORMAL $QUOTANORMAL 0 0 /
fi

while true; do
	read -p $'\e[1m¿Desea añadir quota a algún usuario mas [s/n]: \e[0m' QUOTAUSUARIOSQ
	if [ $QUOTAUSUARIOSQ = s ]; then
		read -p $'\e[1m¿A que usuario desea añadir quota?: \e[0m' USUARIOQUOTA
		read -p $'\e[1m¿Es usuario VIP? [s/n]: \e[0m' VIPQ
		if [ $VIPQ = s ]; then
			setquota -u $USUARIOQUOTA $QUOTAVIP $QUOTAVIP 0 0 /
		else
			setquota -u $USUARIOQUOTA $QUOTANORMAL $QUOTANORMAL 0 0 /
		fi
	else
		break
	fi
done
