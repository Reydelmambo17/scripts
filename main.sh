#!/bin/bash
echo -e "\e[1m\e[32mSe va a configurar la red\e[0m"
source ./confred.sh
echo -e "\e[1m\e[32mRed configurada\e[0m"
echo -e "\e[1m\e[32mSe va a configurar el nfs\e[0m"
source ./nfs.sh
echo -e "\e[1m\e[32mnfs configurado\e[0m"
echo -e "\e[1m\e[32mSe va a configurar el samba\e[0m"
source ./samba.sh
echo -e "\e[1m\e[32msamba confugurado\e[0m"
echo -e "\e[1m\e[32mSe va a configurar el ftp\e[0m"
source ./ftp.sh
echo -e "\e[1m\e[32mftp configurado\e[0m"
echo -e "\e[1m\e[32mSe van a configurar las cuotas\e[0m"
source ./quota.sh
echo -e "\e[1m\e[32mCuotas configuradas\e[0m"
echo -e "\e[1m\e[32mCScript terminado\e[0m"
