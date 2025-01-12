#!/bin/bash

echo 'auth
lcp-echo-failure 3
lcp-echo-interval 60
mtu 1482
mru 1482
require-pap
ms-dns 192.168.2.1
netmask 255.255.255.0
defaultroute
noipdefault
usepeerdns' | sudo tee /etc/ppp/pppoe-server-options
echo '[Service]
WorkingDirectory=/boot/firmware/.PPPwn
ExecStart=/boot/firmware/.PPPwn/pppoe.sh
Restart=never
User=root
Group=root
Environment=NODE_ENV=production
[Install]
WantedBy=multi-user.target' | sudo tee /etc/systemd/system/pppoe.service
echo '[Service]
WorkingDirectory=/boot/firmware/.PPPwn
ExecStart=/boot/firmware/.PPPwn/dtlink.sh
Restart=never
User=root
Group=root
Environment=NODE_ENV=production
[Install]
WantedBy=multi-user.target' | sudo tee /etc/systemd/system/dtlink.service
HSTN=$(hostname | cut -f1 -d' ')
if [[ ! $HSTN == "pppwn" ]] ;then
PHPVER=$(sudo php -v | head -n 1 | cut -d " " -f 2 | cut -f1-2 -d".")
echo 'server {
	listen 80 default_server;
	listen [::]:80 default_server;
	root /boot/firmware/.PPPwn;
	index index.html index.htm index.php;
	server_name _;
	location / {
		try_files $uri $uri/ =404;
	}
	location ~ \.php$ {
    include snippets/fastcgi-php.conf;
    fastcgi_pass unix:/var/run/php/php'$PHPVER'-fpm.sock;
	}
}' | sudo tee /etc/nginx/sites-enabled/default
echo 'www-data	ALL=(ALL) NOPASSWD: ALL' | sudo tee -a /etc/sudoers
sudo /etc/init.d/nginx restart
fi

PPSTAT=$(sudo systemctl list-unit-files --state=enabled --type=service|grep pppoe) 
if [[ ! $PPSTAT == "" ]] ; then
sudo systemctl disable pppoe
fi
if [ -f /boot/firmware/.PPPwn/config.sh ]; then
while true; do
read -p "$(printf '\r\n\r\n\033[36mKonfigurasi ditemukan, Apakah Anda ingin mengubah pengaturan yang disimpan\033[36m(Y|N)?: \033[0m')" cppp
case $cppp in
[Yy]* ) 
break;;
[Nn]* ) 
sudo systemctl start pipwn
echo -e '\033[36mUpdate complete\033[0m'
exit 1
break;;
* ) 
echo -e '\033[31mSilahkan Jawab Y or N\033[0m';;
esac
done
fi
while true; do
read -p "$(printf '\r\n\r\n\033[36mApakah Anda ingin mendeteksi konsol mati dan memulai ulang PPPwn\r\n\r\n\033[36m(Y|N)?: \033[0m')" dlnk
case $dlnk in
[Yy]* ) 
DTLNK="true"
echo -e '\033[32mDeteksi Konsol Mati dinyalakan\033[0m'
break;;
[Nn]* ) 
echo -e '\033[35mDeteksi Konsol Mati dimatikan\033[0m'
DTLNK="false"
break;;
* ) echo -e '\033[31mSilahkan Jawab Y or N\033[0m';;
esac
done
while true; do
read -p "$(printf '\r\n\r\n\033[36mApakah Anda ingin konsol terhubung ke internet setelah PPPwn? (Y|N):\033[0m ')" pppq
case $pppq in
[Yy]* ) 
while true; do
read -p "$(printf '\r\n\r\n\033[36mApakah Anda ingin mengatur nama pengguna dan kata sandi PPPoE?\r\njika Anda memilih tidak maka default ini akan digunakan\r\n\r\nUsername: \033[33mppp\r\n\033[36mPassword: \033[33mppp\r\n\r\n\033[36m(Y|N)?: \033[0m')" wapset
case $wapset in
[Yy]* ) 
while true; do
read -p  "$(printf '\033[33mMasukkan Nama pengguna: \033[0m')" PPPU
case $PPPU in
"" ) 
 echo -e '\033[31mTidak boleh kosong!\033[0m';;
 * )  
if grep -q '^[0-9a-zA-Z_ -]*$' <<<$PPPU ; then 
if [ ${#PPPU} -le 1 ]  || [ ${#PPPU} -ge 33 ] ; then
echo -e '\033[31mNama pengguna harus antara 2 dan 32 karakter\033[0m';
else 
break;
fi
else 
echo -e '\033[31mNama pengguna hanya boleh berisi karakter alfanumerik\033[0m';
fi
esac
done
while true; do
read -p "$(printf '\033[Masukan kata sandi: \033[0m')" PPPW
case $PPPW in
"" ) 
 echo -e '\033[31mTidak boleh kosong!\033[0m';;
 * )  
if [ ${#PPPW} -le 1 ]  || [ ${#PPPW} -ge 33 ] ; then
echo -e '\033[31mKata sandi harus terdiri dari 2 hingga 32 karakter\033[0m';
else 
break;
fi
esac
done
echo -e '\033[36mUsing custom settings\r\n\r\Nama pengguna: \033[33m'$PPPU'\r\n\033[36mKata sandi: \033[33m'$PPPW'\r\n\r\n\033[0m'
break;;
[Nn]* ) 
echo -e '\033[36mMenggunakan pengaturan default\r\n\r\nNama Pengguna: \033[33mppp\r\n\033[36mKata sandi: \033[33mppp\r\n\r\n\033[0m'
 PPPU="ppp"
 PPPW="ppp"
break;;
* ) echo -e '\033[31mSilahkan Jawab Y or N\033[0m';;
esac
done
echo '"'$PPPU'"  *  "'$PPPW'"  192.168.2.2' | sudo tee /etc/ppp/pap-secrets
INET="true"
SHTDN="false"
echo -e '\033[32mPPPoE terpasang\033[0m'
break;;
[Nn]* ) 
echo -e '\033[35mMelewatkan instalasi PPPoE\033[0m'
INET="false"
while true; do
read -p "$(printf '\r\n\r\n\033[36mApakah Anda ingin STB/Raspberry dimatikan setelah pwn sukses\r\n\r\n\033[36m(Y|N)?: \033[0m')" pisht
case $pisht in
[Yy]* ) 
SHTDN="true"
echo -e '\033[32mThe pi will shutdown\033[0m'
break;;
[Nn]* ) 
echo -e '\033[35mThe pi will not shutdown\033[0m'
SHTDN="false"
break;;
* ) echo -e '\033[31mSilahkan Jawab Y or N\033[0m';;
esac
done
break;;
* ) echo -e '\033[31mSilahkan Jawab Y or N\033[0m';;
esac
done
while true; do
read -p "$(printf '\r\n\r\n\033[36mApakah Anda menggunakan adaptor usb ke ethernet untuk koneksi konsol\r\n\r\n\033[36m(Y|N)?: \033[0m')" usbeth
case $usbeth in
[Yy]* ) 
USBE="true"
echo -e '\033[32mUsb ke ethernet sedang digunakan\033[0m'
break;;
[Nn]* ) 
echo -e '\033[35mUsb ke ethernet TIDAK digunakan\033[0m'
USBE="false"
break;;
* ) echo -e '\033[31mSilahkan Jawab Y or N\033[0m';;
esac
done
while true; do
read -p "$(printf '\r\n\r\n\033[36mApakah Anda ingin mengubah versi firmware yang digunakan, defaultnya adalah 11.00\r\n\r\n\033[36m(Y|N)?: \033[0m')" fwset
case $fwset in
[Yy]* ) 
while true; do
read -p  "$(printf '\033[33mMasukkan versi firmware [11.00 | 9.00]: \033[0m')" FWV
case $FWV in
"" ) 
 echo -e '\033[31mTidak boleh kosong!\033[0m';;
 * )  
if grep -q '^[0-9.]*$' <<<$FWV ; then 

if [[ ! "$FWV" =~ ^("11.00"|"9.00")$ ]]  ; then
echo -e '\033[31mVersinya harus 11.00 or 9.00\033[0m';
else 
break;
fi
else 
echo -e '\033[31mThe version must only contain alphanumeric characters\033[0m';
fi
esac
done
echo -e '\033[32mAnda menggunakan '$FWV'\033[0m'
break;;
[Nn]* ) 
echo -e '\033[35mMenggunakan pengaturan default: 11.00\033[0m'
FWV="11.00"
break;;
* ) echo -e '\033[31mPlease answer Y or N\033[0m';;
esac
done
ip link
while true; do
read -p "$(printf '\r\n\r\n\033[36mApakah Anda ingin mengubah antarmuka STB/Raspberry lan, defaultnya adalah eth0\r\n\r\n\033[36m(Y|N)?: \033[0m')" ifset
case $ifset in
[Yy]* ) 
while true; do
read -p  "$(printf '\033[33mMasukkan nilai antarmuka: \033[0m')" IFCE
case $IFCE in
"" ) 
 echo -e '\033[31mCannot be empty!\033[0m';;
 * )  
if grep -q '^[0-9a-zA-Z_ -]*$' <<<$IFCE ; then 
if [ ${#IFCE} -le 1 ]  || [ ${#IFCE} -ge 17 ] ; then
echo -e '\033[31mThe interface must be between 2 and 16 characters long\033[0m';
else 
break;
fi
else 
echo -e '\033[31mThe interface must only contain alphanumeric characters\033[0m';
fi
esac
done
echo -e '\033[32mYou are using '$IFCE'\033[0m'
break;;
[Nn]* ) 
echo -e '\033[35mUsing the default setting: eth0\033[0m'
IFCE="eth0"
break;;
* ) echo -e '\033[31mPlease answer Y or N\033[0m';;
esac
done
if [[ $PITYP == *"Raspberry Pi 4"* ]] || [[ $PITYP == *"Raspberry Pi 5"* ]] ;then
while true; do
read -p "$(printf '\r\n\r\n\033[36mDo you want the pi to act as a flash drive to the console\r\n\r\n\033[36m(Y|N)?: \033[0m')" vusb
case $vusb in
[Yy]* ) 
echo -e '\033[32mThe pi will mount as a drive and goldhen.bin has been placed in the drive\n\033[33mYou must plug the pi into the console usb port using the usb-c of the pi\033[0m'
VUSB="true"
break;;
[Nn]* ) 
echo -e '\033[35mThe pi will not mount as a drive\033[0m'
VUSB="false"
break;;
* ) echo -e '\033[31mPlease answer Y or N\033[0m';;
esac
done
else
VUSB="false"
fi
echo '#!/bin/bash
INTERFACE="'$IFCE'" 
FIRMWAREVERSION="'$FWV'" 
SHUTDOWN='$SHTDN'
USBETHERNET='$USBE'
PPPOECONN='$INET'
VMUSB='$VUSB'
DTLINK='$DTLNK'' | sudo tee /boot/firmware/.PPPwn/config.sh
sudo rm -f /usr/lib/systemd/system/bluetooth.target
sudo rm -f /usr/lib/systemd/system/network-online.target
sudo sed -i 's^sudo bash /boot/firmware/.PPPwn/run.sh \&^^g' /etc/rc.local
echo '[Service]
WorkingDirectory=/boot/firmware/.PPPwn
ExecStart=/boot/firmware/.PPPwn/run.sh
Restart=never
User=root
Group=root
Environment=NODE_ENV=production
[Install]
WantedBy=multi-user.target' | sudo tee /etc/systemd/system/pipwn.service
sudo chmod u+rwx /etc/systemd/system/pipwn.service
sudo chmod u+rwx /etc/systemd/system/pppoe.service
sudo chmod u+rwx /etc/systemd/system/dtlink.service
sudo systemctl enable pipwn
if [[ ! $HSTN == "pppwn" ]] ;then
sudo sed -i "s^$HSTN^pppwn^g" /etc/hosts
sudo sed -i "s^$HSTN^pppwn^g" /etc/hostname
fi
echo -e '\033[36mInstall complete,\033[33m Rebooting\033[0m'
sudo reboot
