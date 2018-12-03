#!/bin/bash
source ./datos.cfg
v=/etc/network/interfaces
echo auto lo > $v
echo iface lo inet loopback >> $v
echo auto eth0 >> $v
echo iface eth0 inet static >> $v
echo address $IP >> $v
echo netmask $MASQ >> $v
echo gateway $PASARELA >> $v
echo nameserver $PASARELA > /etc/resolv.conf
systemctl restart networking.service
