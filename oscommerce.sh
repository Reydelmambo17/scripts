#!/bin/bash
dpkg -s php php-gd php-curl &> /dev/null
if [ $? -eq 1 ]; then
	echo -e "\e[1m\e[31mEl paquete php no esta instalado, se dispondra a su instalación\e[0m"
	apt-get install php php-gd php-curl -y >> /dev/null

else
	echo -e "\e[1m\e[32mEl paquete php ya esta instalado, se continuara con el script\e[0m"
fi
if [ $# -eq 0 ]; then
	read -p "Introduzca el dominio del e-commerce a crear: " dominio
	lista=$dominio
else 
	lista="$@"
fi
bash newdom.sh $lista
bash apache.sh $lista
for a in $lista
do
	if [ -f /etc/bind/dominios/$a ]; then
		echo "El dominio existe"
		if [ -f /etc/apache2/sites-available/$a.conf ]; then
			echo "El alojamiento exisite, se procedeera  la creación del e-commerce"
			cp packages/oscommerce.tar.gz /var/www/$a
			read -p "¿En que lugar de su página quieres que este el e-commerce?: (Escriba la ruta, si lo quiere en la raíz del sitio web, simplemente pulse intro): [/] " ruta
			tar xf /var/www/$a/oscommerce.tar.gz -C /var/www/$a/public_html/$ruta
			chmod 777 /var/www/$a/public_html/$ruta/includes/configure.php
			chmod 777 /var/www/$a/public_html/$ruta/admin/includes/configure.php
			PASSWDDB="$(openssl rand -base64 12)"
			MAINDB=${a//[^a-zA-Z0-9]/_}
		    	mysql -e "CREATE DATABASE ${MAINDB}_oscom /*\!40100 DEFAULT CHARACTER SET utf8 */;"
		    	mysql -e "CREATE USER ${MAINDB}@localhost IDENTIFIED BY '${PASSWDDB}';"
		    	mysql -e "GRANT ALL PRIVILEGES ON ${MAINDB}_oscom.* TO '${MAINDB}'@'localhost';"
		    	mysql -e "FLUSH PRIVILEGES;"
			clear
			echo "Accede a www.$a para continuar con la instalación"
			echo "Necesitaras esta información para completar la instalación"
			echo "Database Server: localhost"
			echo "Username: ${MAINDB}"
			echo "Password: ${PASSWDDB}"
			echo "Database Name: ${MAINDB}_oscom"
			read -n 1 -s -r -p "Cuando haya terminado, pulse cualquer tecla"
			echo ""
			chmod 644 /var/www/$a/public_html/$ruta/includes/configure.php
			chmod 644 /var/www/$a/public_html/$ruta/admin/includes/configure.php
			rm -rf /var/www/$a/public_html/$ruta/install
			echo "E-commerce creado correctamente"
			read -n 1 -s -r -p "Pulse cualquier tecla para salir"
			echo ""
		else
			echo "El alojamiento no existe"
		fi
	else
		echo "El dominio no existe"
		exit 1
	fi
done
