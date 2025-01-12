#!/bin/bash

if [ ! -f /boot/firmware/.PPPwn/config.sh ]; then
INTERFACE="eth0"
DTLINK=false
else
source /boot/firmware/.PPPwn/config.sh
fi

if [ $DTLINK = true ] ; then
echo -e "\033[32mMonitoring link\033[0m\n" | sudo tee /dev/tty1
coproc read -t 5 && wait "$!" || true
while [[ $(ethtool $INTERFACE) == *"Link detected: yes"* ]]
do
    coproc read -t 5 && wait "$!" || true
done
sudo systemctl stop pppoe
sudo killall pppoe-server
sudo ip link set $INTERFACE down
sudo iptables -P INPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -P OUTPUT ACCEPT
sudo iptables -t nat -F
sudo iptables -t mangle -F
sudo iptables -F
sudo iptables -X
sudo sysctl net.ipv4.ip_forward=0
sudo sysctl net.ipv4.conf.all.route_localnet=0
echo -e "\033[32mMengulang PPPwn\033[0m\n" | sudo tee /dev/tty1
sudo systemctl restart pipwn
fi