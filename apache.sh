#!/bin/bash
source ./datos.cfg
dpkg -s apache2 &> /dev/null
if [ $? -eq 1 ]; then
	echo -e "\e[1m\e[31mEl paquete apache2 no esta instalado, se dispondra a su instalación\e[0m"
	apt-get install apache2 -y >> /dev/null
else
	echo -e "\e[1m\e[32mEl paquete apache2 ya esta instalado, se continuara con el script\e[0m"
fi

if [ $# -eq 0 ]; then
	read -p "Introduzca el dominio del sitio web crear: " dominio
	lista=$dominio
else 
	lista="$@"
fi

for a in $lista
do
	if [ -f /etc/bind/dominios/$a ]; then
		echo "El dominio existe"
		if [ ! -f /etc/apache2/sites-available/$a.conf ]; then
			echo "Se procedeera  la creación del espacio web"
			cat > /etc/apache2/sites-available/$a.conf << eof
<VirtualHost *:80>
	ServerName $a
	Redirect permanent / http://www.$a
</VirtualHost>

<VirtualHost *:80>
	ServerName www.$a

	ServerAdmin admin@$a
	DocumentRoot /var/www/$a/public_html

	ErrorLog \${APACHE_LOG_DIR}/error.log
	CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
eof
			mkdir -p /var/www/$a/public_html
			cat > /var/www/$a/public_html/index.html << eof
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <title>w2012r2.ns.msn.com</title>
    <style>
        h1 {
            text-align: center;
        }
        p {
            text-align: center;
        }
    </style>
</head>
<html>
	<body>
		<h1>Funciona!!!!</h1>
		<p>Esta es la pagina principal de www.$a, pero aparentemente el administrador todavia no ha subido nada...</p>
	</body>
</html>
eof
			a2ensite $a >> /dev/null
			#creación usuario
			usuario=admin@$a
			useradd $usuario -d /var/www/$a -s /bin/bash
			passwd $usuario
			chown -R $usuario:$usuario /var/www/$a
			#fin creación usuario
			#quotas
			read -p "¿Es usuario VIP? [s/n]:" VIPQ
			if [ $VIPQ = s ]; then
				setquota -u $usuario $QUOTAVIP $QUOTAVIP 0 0 /
			else
				setquota -u $usuario $QUOTANORMAL $QUOTANORMAL 0 0 /
			fi
			#fin quotas
			systemctl reload apache2
			echo "Sitio creado correctamente"
		else
			echo "El sitio ya esta creado"
		fi
	else
		echo "El dominio no existe"
		exit 1
	fi
done
