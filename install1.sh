#!/bin/bash
sed -i "1 i  Server = https://mirrors.ustc.edu.cn/archlinux/\$repo/os/\$arch\nServer = http://mirrors.163.com/archlinux/\$repo/os/\$arch \nServer = http://mirrors.bfsu.edu.cn/archlinux/\$repo/os/\$arch\n" /etc/pacman.d/mirrorlist
if [ $? -eq 0 ]; then
  echo " 换源完成"
else
  echo " 换源失败"
  exit -1
fi

timedatectl set-ntp true
if [ $? -eq 0 ]; then
  echo " 时间校准完成"
else
  echo " 时间校准失败"
  exit -1
fi

echo -e "\n" | pacman -Syy
if [ $? -eq 0 ]; then
  echo " pacman更新完成"
else
  echo " pacman更新失败"
  exit -1
fi

read -p "if had Partition ? make sure you have /mnt && /mnt/boot [y/n]" -n 1
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo -e "\n" | pacstrap /mnt base base-devel linux-firmware
  if [ $? -eq 0 ]; then
    echo "安装基础组件完成"
  else
    echo "安装基础组件失败"
    exit -1
  fi

else
  echo "exit sh1 "
  exit 0
fi

echo "[1]install linux linux-headers    -------[default]"
echo "[2]if install linux-zen linux-zen-headers? "
echo "[3]if install linux-lts linux-lts-headers?"
read -n1 -p "which would you want to install ?[1/2/3]" REPLY
if [[ $REPLY =~ ^[1]$ ]]; then
  echo -e "\n" | pacstrap /mnt linux linux-headers
  if [ $? -eq 0 ]; then
    echo "linux linux-headers 安装完成"
  else
    echo "linux linux-headers 安装失败"
    exit -1
  fi

elif [[ $REPLY =~ ^[2]$ ]]; then
  echo -e "\n" | pacstrap /mnt linux-zen linux-zen-headers
  if [ $? -eq 0 ]; then
    echo "linux-zen linux-zen-headers 安装完成"
  else
    echo "linux-zen linux-zen-headers 安装失败"
    exit -1
  fi

elif [[ $REPLY =~ ^[3]$ ]]; then
  echo -e "\n" | pacstrap /mnt linux-lts linux-lts-headers
  if [ $? -eq 0 ]; then
    echo "linux-lts linux-lts-headers 安装完成"
  else
    echo "linux-lts linux-lts-headers 安装失败"
    exit -1
  fi

fi

mv /mnt/etc/fstab /mnt/etc/fstab.bak
genfstab -U /mnt >/mnt/etc/fstab
if [ $? -eq 0 ]; then
  echo "生成fstab完成"
else
  echo "生成fstab失败"
  exit -1
fi

cp ./install2.sh /mnt
echo "脚本1结束,请执行脚本2"

arch-chroot /mnt
exit 0
