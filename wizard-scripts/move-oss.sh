#!/bin/bash

vi /etc/hosts

ssh old-oss "systemctl stop mysql samba samba-printserver  oss-api cups"
systemctl stop mysql samba samba-printserver  oss-api cups
mv /root/.my.cnf /root/.my.cnf-orig
mv /var/lib/samba/ /var/lib/samba-orig
mv /var/lib/mysql /var/lib/mysql-orig
mv /opt/oss-java/conf/oss-api.properties /opt/oss-java/conf/oss-api.properties-orig
mv /var/lib/printserver/ /var/lib/printserver-orig
mv /etc/cups /etc/cups-orig

scp old-oss:/root/.my.cnf /root/.my.cnf
scp old-oss:/opt/oss-java/conf/oss-api.properties /opt/oss-java/conf/oss-api.properties
rsync -aAv old-oss:/var/lib/samba/ /var/lib/samba/
rsync -aAv old-oss:/var/lib/mysql/ /var/lib/mysql/
rsync -aAv old-oss:/var/lib/printserver/ /var/lib/printserver/
rsync -aAv old-oss:/etc/cups/ /etc/cups/
rsync -aAv old-oss:/var/lib/printserver/ /var/lib/printserver/
rsync -aAv old-oss:/var/lib/squidGuard/ /var/lib/squidGuard/ 
rsync -aAv old-oss:/etc/squid/ /etc/squid/
oss_api.sh PUT devices/refreshConfig
oss_api.sh PUT softwares/saveStates
nohup rsync -aAv old-oss:/srv/itool/ /srv/itool/ &
nohup rsync -aAv old-oss:/home/ /home/ &

systemctl start mysql samba samba-printserver  oss-api cups

