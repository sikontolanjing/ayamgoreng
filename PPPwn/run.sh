#!/bin/bash

if [ ! -f /boot/firmware/.PPPwn/config.sh ]; then
INTERFACE="eth0" 
FIRMWAREVERSION="11.00" 
SHUTDOWN=true
PPPOECONN=false
DTLINK=true
else
source /boot/firmware/.PPPwn/config.sh
fi
echo '1-1' | sudo tee /sys/bus/usb/drivers/usb/unbind 
echo '1-1' | sudo tee /sys/bus/usb/drivers/usb/bind
PITYP=$(tr -d '\0' </proc/device-tree/model) 
if [[ $PITYP == *"Raspberry Pi"* ]] ;then
coproc read -t 15 && wait "$!" || true
CPPBIN="pppwn11"
else
coproc read -t 5 && wait "$!" || true
CPPBIN="pppwn64"
fi
arch=$(getconf LONG_BIT)
if [ $arch -eq 32 ] && [ $CPPBIN = "pppwn64" ] ; then
CPPBIN="pppwn7"
fi
echo -e "\n\n\033[36m _____  _____  _____                 
|  __ \\|  __ \\|  __ \\
| |__) | |__) | |__) |_      ___ __
|  ___/|  ___/|  ___/\\ \\ /\\ / / '_ \\
| |    | |    | |     \\ V  V /| | | |
|_|    |_|    |_|      \\_/\\_/ |_| |_|\033[0m
\n\033[33mhttps://github.com/TheOfficialFloW/PPPwn\033[0m\n" | sudo tee /dev/tty1
echo -e "\033[1;45m  PPPWN_64_EXTREME_EDITION  \033[0m\n" | sudo tee /dev/tty1
sudo systemctl stop pppoe

echo -e "\n\033[36mSTB PS4 AUTO HEN \033[92m\nFirmware:\033[93m $FIRMWAREVERSION\033[92m\nKoneksi:\033[93m $INTERFACE\033[0m" | sudo tee /dev/tty1
echo -e "\033[92mPS4 Hen PPPwn:\033[93m C++ PPPWN 64 EXTREME EDITION $CPPBIN \033[0m" | sudo tee /dev/tty1
if [ $PPPOECONN = true ] ; then
   echo -e "\033[92mKONEKSI INTERNET:\033[93m NYALA\033[0m" | sudo tee /dev/tty1
else   
   echo -e "\033[92mKONEKSI INTERNET:\033[93m MATI\033[0m" | sudo tee /dev/tty1
fi
if [[ ! $(ethtool $INTERFACE) == *"Link detected: yes"* ]]; then
   echo -e "\033[31mMENUNGGU SAMBUNGAN\033[0m" | sudo tee /dev/tty1
   while [[ ! $(ethtool $INTERFACE) == *"Link detected: yes"* ]]
   do
      coproc read -t 2 && wait "$!" || true
   done
   echo -e "\033[32mKABEL LAN TERSANDUNG EH TERSAMBUNG\033[0m\n" | sudo tee /dev/tty1
fi
PIIP=$(hostname -I) || true
if [ "$PIIP" ]; then
   echo -e "\n\033[92mIP: \033[93m $PIIP\033[0m" | sudo tee /dev/tty1
fi
echo -e "\n\033[95mSiap untuk koneksi konsol\033[0m\n" | sudo tee /dev/tty1
while [ true ]
do
ret=$(sudo /boot/firmware/.PPPwn/$CPPBIN --interface "$INTERFACE" --fw "${FIRMWAREVERSION//.}" --stage1 "/boot/firmware/.PPPwn/stage1_$FIRMWAREVERSION.bin" --stage2 "/boot/firmware/.PPPwn/stage2_$FIRMWAREVERSION.bin")
if [ $ret -ge 1 ] ; then
        echo -e "\033[1;45m\nMantab BOS sukses jailbreaknya PPPwn! HEPI GAMING BOSKUH BOSKUH \033[0m\n" | sudo tee /dev/tty1
		if [ $PPPOECONN = true ] ; then
			sudo systemctl start pppoe
			if [ $DTLINK = true ] ; then
				sudo systemctl start dtlink
			fi
		else
			if [ $SHUTDOWN = true ] ; then
				coproc read -t 5 && wait "$!" || true
				sudo poweroff
			else
				if [ $DTLINK = true ] ; then
					sudo systemctl start dtlink
				else
					sudo ip link set $INTERFACE down
				fi
        	fi
		fi
        exit 0
   else
        echo -e "\033[33m\nGagal Bos sabar mencoba ulang sampai mencret.............\033[0m\n" | sudo tee /dev/tty1
fi
done
