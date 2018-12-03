#!/bin/bash

dpkg -s samba &> /dev/null
if [ $? -eq 1 ]; then
	echo -e "\e[1m\e[31mEl paquete samba no esta instalado, se dispondra a su instalación\e[0m"
	apt-get install samba -y >> /dev/null
else
	echo -e "\e[1m\e[32mEl paquete samba ya esta instalado, se continuara con el script\e[0m"
fi
mv /etc/samba/smb.conf /etc/samba/smb.conf.bak
touch /etc/samba/smb.conf
cat >> /etc/samba/smb.conf << eof
[global]
	workgroup = WORKGROUP
	dns proxy = no
	log file = /var/log/samba/log.%m
	max log size = 1000
	syslog = 0
	panic action = /usr/share/samba/panic-action %d
	server role = standalone server
	passdb backend = tdbsam
	obey pam restrictions = yes
	unix password sync = yes
	passwd program = /usr/bin/passwd %u
	passwd chat = *Escriba\snueva\s*\scontaseña:* %n\n *Reescribe\snueva\s*\scontraseña:* %n\n *contraseña\sactualizada\scorrectamente* .
	pam password change = yes
	map to guest = bad user
	usershare allow guests = yes
smb
eof
read -p "¿Desea agregar los directorios personales a la compartición samba? [s/n]: " homes
if [ $homes = s ]; then
	cat >> /etc/samba/smb.conf << eof
	[homes]
	comment = Home Directories
	browseable = yes
	read only = no
	create mask = 0755
	directory mask = 0755
	valid users = %S
eof
fi
read -p "¿Desea crear una compartición pública? [s/n]: " public
	if [ $public = s ]; then
		read -p "¿Como quiere llamar a la compartición?: " publicname
		echo "[$publicname]" >> /etc/samba/smb.conf
		read -p "Escriba la ruta absoluta de la compartición: " publicpath
		mkdir -p $publicpath
		chown -R nobody:nogroup $publicpath
		echo "	path = $publicpath" >> /etc/samba/smb.conf
		cat >> /etc/samba/smb.conf << eof
	only guest = yes
	writeable = yes
	printable = no

eof
	fi
read -p "Desea crear una compartición privada? [s/n]: " private
	if [ $private = s ]; then
		read -p "Como quiere llamar a la compartición?: " privatename
		echo "[$privatename]" >> /etc/samba/smb.conf
		read -p "Escriba la ruta absoluta de la compartición: " privatepath
		mkdir -p $privatepath
		chown -R nobody:nogroup $privatepath
		echo "	path = $privatepath" >> /etc/samba/smb.conf
		read -p "¿Que usuario puede tener acceso a esta carpeta?: " privateuser
		echo "Introducca ahora la contraseña de $privateuser"
		smbpasswd -a $privateuser
		privateusers=$privateuser
		while true; do
			read -p "Desea añadir algún usuario mas a la compartición [s/n]: " privatemoreusers
			if [ $privatemoreusers = s ]; then
				read -p "¿Que usuario puede tener acceso a esta carpeta?: " privateuser
				echo "Introducca ahora la contraseña de $privateuser"
				smbpasswd -a $privateuser
				privateusers="$privateusers $privateuser"
			else
				break
			fi
		done
		cat >> /etc/samba/smb.conf << eof
	valid users = $privateusers
	public = no
	writeable = yes
	printeable = no
eof
	fi
systemctl restart smbd
