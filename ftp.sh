#!/bin/bash

source ./datos.cfg

dpkg -s proftpd-basic &> /dev/null
if [ $? -eq 1 ]; then
	echo -e "\e[1m\e[31mEl paquete proftpd no esta instalado, se dispondra a su instalación\e[0m"
	apt-get install proftpd -y >> /dev/null
else
	echo -e "\e[1m\e[32mEl paquete proftpd ya esta instalado, se continuara con el script\e[0m"
fi

mv /etc/proftpd/proftpd.conf /etc/proftpd/proftpd.conf.bak
touch /etc/proftpd/proftpd.conf
cat >> /etc/proftpd/proftpd.conf << eof
Include /etc/proftpd/modules.conf
UseIPv6 off
IdentLookups			off
ServerName				"Pablo-SOR"
ServerType				standalone
DeferWelcome			off
MultilineRFC2228		on
DefaultServer			on
ShowSymlinks			on
TimeoutNoTransfer		600
TimeoutStalled			600
TimeoutIdle				1200
DisplayLogin            welcome.msg
DisplayChdir           	.message true
ListOptions            	"-l"
DenyFilter				\*.*/
DefaultRoot				~
RequireValidShell		off
Port					21
MaxInstances			30
User					proftpd
Group					nogroup
Umask					022  022
AllowOverwrite			on
TransferLog 			/var/log/proftpd/xferlog
SystemLog 				/var/log/proftpd/proftpd.log
<IfModule mod_quotatab.c>
	QuotaEngine 		off
</IfModule>
<IfModule mod_ratio.c>
	Ratios 				off
</IfModule>
<IfModule mod_delay.c>
	DelayEngine 		on
</IfModule>
<IfModule mod_ctrls.c>
	ControlsEngine      off
	ControlsMaxClients  2
	ControlsLog         /var/log/proftpd/controls.log
	ControlsInterval    5
	ControlsSocket      /var/run/proftpd/proftpd.sock
</IfModule>
<IfModule mod_ctrls_admin.c>
	AdminControlsEngine off
</IfModule>
<Anonymous ~ftp>
	User				ftp
	Group				nogroup
	UserAlias			anonymous ftp
	DirFakeUser	on ftp
	DirFakeGroup on ftp
	RequireValidShell	off
	MaxClients			10
	DisplayLogin		welcome.msg
	DisplayChdir		.message
	<Directory *>
		<Limit WRITE>
			DenyAll
		</Limit>
	</Directory>
	<Directory incoming>
		Umask			022  022
		<Limit READ WRITE>
			DenyAll
		</Limit>
		<Limit STOR>
			AllowAll
		</Limit>
	</Directory>
</Anonymous>
Include /etc/proftpd/conf.d/
eof
systemctl restart proftpd.service
