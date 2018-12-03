#!/bin/bash

source ./datos.cfg

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
eof

echo "[$publicname]" >> /etc/samba/smb.conf
mkdir -p $publicpath
chown -R nobody:nogroup $publicpath
echo "	path = $publicpath" >> /etc/samba/smb.conf
cat >> /etc/samba/smb.conf << eof
	only guest = yes
	writeable = yes
	printable = no

eof

echo "[$privatename]" >> /etc/samba/smb.conf
mkdir -p $privatepath
chown -R nobody:nogroup $privatepath
chmod 777 $privatepath
echo "	path = $privatepath" >> /etc/samba/smb.conf
for privateuser in ${privateusers//,/ }; do
	echo -e "\e[1mIntroducca ahora la contraseña de "$privateuser"\e[0m"
	smbpasswd -a $privateuser
done
cat >> /etc/samba/smb.conf << eof
	valid users = $privateusers
	public = no
	writeable = yes
	printeable = no
eof

systemctl restart smbd
