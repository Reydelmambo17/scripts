#!/bin/bash

for ip in 10.229.1.{1..254}; do
#for ip in 127.0.0.1; do
	ping -c 1 $ip >> /dev/null
	if [ $? -eq	0 ]; then
		echo -e "\e[1m\e[32mDestino $ip es accesible!!\e[0m"
		showmount -e $ip >> /dev/null
		if [ $? -eq 0 ]; then
			echo -e "\e[1m\\e[32m	$ip esta compartiendo!!\e[0m"
			mkdir -p /shares/$ip
			mount $ip: /shares/$ip		
			echo -e "\e[1m		Montando $ip en /shares/$ip"
			mkdir -p /sharecopies/$ip
			cp -r /shares/$ip /sharecopies/
			echo -e "\e[1m		Copiando el contenido de /shares/$ip a /sharecopies/$ip"
			umount /shares/$ip
			echo "		Desmontando /shares/$ip"
			rm -rf /shares/$ip
			echo -e "\e[1m		Borrando /shares/$ip"
		else
			echo -e "\e[1m\e[31m	$ip no esta compartiendo!!\e[0m"
		fi
	else
		echo -e "\e[1m\e[31mDestino $ip es inaccesible!!\e[0m"
	fi
done
rm -rf /shares
