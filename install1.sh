#!/bin/bash

sed -i "1 i  Server = https://mirrors.ustc.edu.cn/archlinux/\$repo/os/\$arch\nServer = http://mirrors.163.com/archlinux/\$repo/os/\$arch \nServer = http://mirrors.bfsu.edu.cn/archlinux/\$repo/os/\$arch\n" /etc/pacman.d/mirrorlist
echo " 换源成功  "

timedatectl set-ntp true
echo " 时间校准完成"

echo -e "\n" | pacman -Syy >/dev/null
echo " pacman更新完成"

read -p "if had Partition ? make sure you have /mnt && /mnt/boot [y/n]" -n 1
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo -e "\n" | pacstrap /mnt linux linux-headers >/dev/null
  echo "linux linux-headers 安装完成"
else
  echo "exit sh1 "
  exit 0
fi

echo -e "\n" | pacstrap /mnt base base-devel linux-firmware >/dev/null
echo "安装基础组件"

read -n1 -p "if install linux linux-headers in /mnt ?[y/n]" REPLY
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo -e "\n" | pacstrap /mnt linux linux-headers >/dev/null
  echo "linux linux-headers 安装完成"
fi
#### TODO:其他选项

mv /mnt/etc/fstab /mnt/etc/fstab.bak
genfstab -U /mnt >/mnt/etc/fstab
echo "生成fstab"

cp ./install2.sh /mnt
echo "脚本1结束,请执行脚本2"

arch-chroot /mnt
exit 0
