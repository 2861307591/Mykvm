#!/bin/bash
#Author: GZ
#Start network configuration
read -p "Please Enter your hostname: " hostname
read -p "Please Enter yout IP Address: " IP
read -p "Please Enter yout GATEWAY: " GATEWAY
read -p "Please Enter yout DNS: " DNS
echo $hostname  > /etc/hostname
cat >  /etc/sysconfig/network-scripts/ifcfg-em1 <<EOF
TYPE="Ethernet"
OTPROTO=static
DEFROUTE="yes"
NAME="em1"
DEVICE="em1"
ONBOOT="yes"
IPADDR=${IP}
GATEWAY=${GATEWAY}
DNS1=${DNS}
EOF
systemctl restart network
read -n1 -p "Do you want to close the firewalld [Y/N]? " answer
case $answer in
Y | y)
   systemctl stop firewalld
   sed -i "s/SELINUX=.*/SELINUX=Disabled/" /etc/selinux/config
   setenforce 0
;;
N | n) echo
  echo -e "\e[;033m OK,goodbye \e[0m"
;;
esac
HOSTNAME1=`cat /etc/hostname`
IPADDR1=`egrep "IPADDR" /etc/sysconfig/network-scripts/ifcfg-em1`
DNS1=`egrep "DNS1" /etc/sysconfig/network-scripts/ifcfg-em1`
GATEWAY1=`egrep "GATEWAY" /etc/sysconfig/network-scripts/ifcfg-em1`
FIREWALLD1=`systemctl status firewalld | egrep Active | awk -F: '{print $2}' | awk '{print $1 $2}'`
#Start system optimization
#Remote 5 minutes without automatic logout
sed -i '$ a export TMOUT=300' /etc/profile
sed -i "/HISTSIZE/ s|HISTSIZE=[0-9]*|HISTSIZE=200|" /etc/profile
source /etc/profile
#The kernel optimization
cat >> /etc/security/limits.conf <<EOF
soft nofile 1024000
hard nofile 1024000
root soft nofile 1024000
root hard nofile 1024000
EOF
cat > /etc/sysctl.conf <<EOF
fs.file-max = 999999
net.ipv4.tcp_tw_reuse = 1
ner.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_fin_timeout = 30  
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.ip_local_port_range = 1024 65000  
net.ipv4.tcp_rmem = 10240 87380 12582912  
net.ipv4.tcp_wmem = 10240 87380 12582912  
net.core.netdev_max_backlog = 8096  
net.core.rmem_default = 6291456  
net.core.wmem_default = 6291456  
net.core.rmem_max = 12582912  
net.core.wmem_max = 12582912 
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_tw_recycle = 1  
net.core.somaxconn=262114 
net.ipv4.tcp_max_orphans=262114
EOF
sysctl -p &> /dev/null
echo
echo -e "\e[;34m --------------------------- \n
now yout hostname is ${HOSTNAME1} \n
your IPADDR1 is ${IPADDR1} \n
your DNS1 IS ${DNS1} \n
your GATEWAY IS ${GATEWAY1} \n
you firewalld status is ${FIREWALLD1} \n
your /etc/systcl.conf is \n `cat /etc/sysctl.conf`
---------------------------- \n
\e[0m" 

