echo "test"
#getcwd()

ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
 hwclock --systohc --utc

echo "en_US.UTF-8 UTF-8 \nzh_CN.UTF-8 \nUTF-8 \nzh_TW.UTF-8 UTF-8" >>/etc/locale.gen
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf


#   echo $ > /etc/hostname


echo -e "\n" | pacman -S grub  efibootmgr dosfstools

# pacman -S os-prober  ntfs-3g

grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub --recheck
grub-mkconfig -o /boot/grub/grub.cfg

echo "%wheel ALL=(ALL) ALL ">> /etc/sudoers



# passwd
# useradd -m -G wheel username
# passwd username


echo -e "\n" | pacman -S noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra ttf-sarasa-gothic adobe-source-han-sans-cn-fonts adobe-source-han-serif-cn-fonts


echo -e "\n" | pacman -S networkmanager
systemctl enable NetworkManager


echo " [archlinuxcn] \n Include = /etc/pacman.d/archlinuxcn-mirrorlist " >>/etc/pacman.conf

echo "Server = https://mirrors.ustc.edu.cn/archlinuxcn/\$arch \nServer = https://mirrors.hit.edu.cn/archlinuxcn/\$arch" > /etc/pacman.d/archlinuxcn-mirrorlist

 pacman -Syy archlinuxcn-keyring

 pacman -S fcitx fcitx-im fcitx-libpinyin 
 pacman -S archlinuxcn-mirrorlist-git


pacman -S bluez bluez-utils pulseaudio-bluetooth
modprobe btusb
systemctl enable bluetooth.service


  pacman -S zsh oh-my-zsh-git zsh-syntax-highlighting zsh-autosuggestions autojump
# sudo chsh -s /bin/zsh username
  ln -s /usr/share/zsh/plugins/zsh-syntax-highlighting /usr/share/oh-my-zsh/custom/plugins/
  ln -s /usr/share/zsh/plugins/zsh-autosuggestions /usr/share/oh-my-zsh/custom/plugins/



# ~/.pam_environment
#
# GTK_IM_MODULE DEFAULT=fcitx
#QT_IM_MODULE  DEFAULT=fcitx
# XMODIFIERS    DEFAULT=@im=fcitx

# [archlinuxcn]
# #Server = https://repo.archlinuxcn.org/$arch
# #Server = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/$arch
# Include = /etc/pacman.d/archlinuxcn-mirrorlist






# ~/.zshrc
# autojump git zsh-syntax-highlighting zsh-autosuggestions