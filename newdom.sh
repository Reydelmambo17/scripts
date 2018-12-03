#!/bin/bash
echo $@
dpkg -s bind9 &> /dev/null
if [ $? -eq 1 ]; then
	echo -e "\e[1m\e[31mEl paquete bind9 no esta instalado, se dispondra a su instalación\e[0m"
	apt-get install bind9 -y >> /dev/null
	mkdir -p /etc/bind/dominios
	cat /etc/resolv.conf | grep "nameserver 127.0.0.1" >> /dev/null
	if [ $? -eq 1 ]; then
		echo nameserver 127.0.0.1 >> /etc/resolv.conf
	fi
else
	echo -e "\e[1m\e[32mEl paquete bind9 ya esta instalado, se continuara con el script\e[0m"
fi

if [ $# -eq 0 ]; then
	read -p "Introduzca en dominio a crear: " dominio
	lista=$dominio
else 
	lista="$@"
fi

for a in $lista; do
	if [ -f /etc/bind/dominios/$a ]; then
		echo "Dominio en uso" $a
	else
		echo "Dominio $a no en uso, se procedeera a su creación"
		cat >> /etc/bind/named.conf.local << eof
zone "$a" {
	type master;
	file "/etc/bind/dominios/$a";
};
eof
		cat >> /etc/bind/dominios/$a << eof
;
; BIND zone file for $a
;
 
\$TTL	3D
@		IN	SOA	$a	admin.$a. (
				$(date +%Y%m%d)01	; serial
				8H		; refresh
				2H		; retry
				4W		; expire
				1D )		; minimum
;
			NS	$a.
			A	$(hostname -I)
 
www		IN	A	$(hostname -I)
ftp		IN	A	$(hostname -I)
samba		IN	A	$(hostname -I)
eof
		systemctl restart bind9
		nslookup $a
	fi
done
