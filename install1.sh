#!/bin/bash
sed -i "1 i  Server = http://mirrors.bfsu.edu.cn/archlinux/\$repo/os/\$arch\nServer = https://mirrors.ustc.edu.cn/archlinux/\$repo/os/\$arch\nServer = http://mirrors.163.com/archlinux/\$repo/os/\$arch \n" /etc/pacman.d/mirrorlist
if [ $? -eq 0 ]; then
  echo " change mirror success"
else
  echo " change mirrorfailed"
  exit -1
fi

timedatectl set-ntp true
if [ $? -eq 0 ]; then
  echo " time verification  success"
else
  echo " time verification failed"
  exit -1
fi

 pacman -Syy --noconfirm
if [ $? -eq 0 ]; then
  echo " pacman update  success"
else
  echo " pacman update failed"
  exit -1
fi

read -p "if had Partition ? make sure you have /mnt && /mnt/boot [y/n]" -n 1
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo -e "\n" | pacstrap /mnt base base-devel linux-firmware
  if [ $? -eq 0 ]; then
    echo "install base success"
  else
    echo "install base failed"
    exit -1
  fi

else
  echo "exit sh1 "
  exit 0
fi

echo "[1]install linux linux-headers    -------[default]"
echo "[2]if install linux-zen linux-zen-headers? "
echo "[3]if install linux-lts linux-lts-headers?"
echo "[4]if install linux-hardened linux-hardened-headers?"
read -n1 -p "which would you want to install ?[1/2/3]" REPLY
if [[ $REPLY =~ ^[1]$ ]]; then
  echo -e "\n" | pacstrap /mnt linux linux-headers
  if [ $? -eq 0 ]; then
    echo "linux linux-headers  install  success"
  else
    echo "linux linux-headers  install failed"
    exit -1
  fi

elif [[ $REPLY =~ ^[2]$ ]]; then
  echo -e "\n" | pacstrap /mnt linux-zen linux-zen-headers
  if [ $? -eq 0 ]; then
    echo "linux-zen linux-zen-headers  install  success"
  else
    echo "linux-zen linux-zen-headers  install failed"
    exit -1
  fi

elif [[ $REPLY =~ ^[3]$ ]]; then
  echo -e "\n" | pacstrap /mnt linux-lts linux-lts-headers
  if [ $? -eq 0 ]; then
    echo "linux-lts linux-lts-headers  install  success"
  else
    echo "linux-lts linux-lts-headers  install failed"
    exit -1
  fi

elif [[ $REPLY =~ ^[4]$ ]]; then
  echo -e "\n" | pacstrap /mnt linux-hardened linux-hardened-headers
  if [ $? -eq 0 ]; then
    echo "linux-lts linux-lts-headers  install  success"
  else
    echo "linux-lts linux-lts-headers  install failed"
    exit -1
  fi

fi

mv /mnt/etc/fstab /mnt/etc/fstab.bak
genfstab -U /mnt >/mnt/etc/fstab
if [ $? -eq 0 ]; then
  echo "build fstab success"
else
  echo "build fstabfailed"
  exit -1
fi

cp ./install2.sh /mnt
echo "sh1 over , run sh2 "

arch-chroot /mnt
exit 0
