#!/bin/bash
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
hwclock --systohc --utc
if [ $? -eq 0 ]; then
    echo "Time zone change  success "
else
    echo "Time zone change  failed "
    exit -1
fi

echo -e "en_US.UTF-8 UTF-8 \nzh_CN.UTF-8 UTF-8 \nzh_TW.UTF-8 UTF-8" >>/etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >/etc/locale.conf
if [ $? -eq 0 ]; then
    echo "(Mainland China) Language change success "
else
    echo "(Mainland China) Language change failed "
    exit -1
fi

echo -e " [archlinuxcn] \n Include = /etc/pacman.d/archlinuxcn-mirrorlist " >>/etc/pacman.conf
echo -e "Server = https://mirrors.ustc.edu.cn/archlinuxcn/\$arch \nServer = https://mirrors.hit.edu.cn/archlinuxcn/\$arch" >/etc/pacman.d/archlinuxcn-mirrorlist
rm /etc/pacman.d/gnupg -rf
pacman-key --init
pacman-key --populate
 pacman -Syy archlinuxcn-keyring  --noconfirm
 pacman -S archlinuxcn-mirrorlist-git  --noconfirm 
if [ $? -eq 0 ]; then
    echo "change mirrors uccess"
else 
    echo "change mirror error"
    exit -1
fi

 pacman -S grub efibootmgr dosfstools  --noconfirm
if [ $? -eq 0 ]; then
    echo "grub success"
else
    echo "grub failed"
    exit -1
fi

read -n1 -p "ntfs-3g install?[y/n]" REPLY
if [[ $REPLY =~ ^[Yy]$ ]]; then
  pacman -S os-prober ntfs-3g  --noconfirm
    if [ $? -eq 0 ]; then
        echo "os-prober success"
    else
        echo "os-prober failed"
        exit -1
    fi

fi

echo "build grub "
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub --recheck
grub-mkconfig -o /boot/grub/grub.cfg
if [ $? -eq 0 ]; then
    echo "grub success"
else
    echo "grub failed"
    exit -1
fi

echo "fonts installing  (Google Noto Fonts 字体,思源黑体, 思源宋体,更纱黑体)"
 pacman -S noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra ttf-sarasa-gothic adobe-source-han-sans-cn-fonts adobe-source-han-serif-cn-fonts  --noconfirm
if [ $? -eq 0 ]; then
    echo "install fonts success"
else
    echo "install fonts failed"
    exit -1
fi

echo "network manager installing"
 pacman -S networkmanager  --noconfirm
systemctl enable NetworkManager
if [ $? -eq 0 ]; then
    echo "network managersuccess"
else
    echo "network managerfailed"
    exit -1
fi

read -p "hostname:" userhostname
echo $userhostname >>/etc/hostname
if [ $? -eq 0 ]; then
    echo "change hostname success "
else
    echo "change hostname failed "
    exit -1
fi

echo "root passed:"
passwd

echo "%wheel ALL=(ALL) ALL " >>/etc/sudoers

echo "blue tooth installing"
pacman -S bluez bluez-utils pulseaudio-bluetooth  --noconfirm
modprobe btusb
systemctl enable bluetooth.service
if [ $? -eq 0 ]; then
    echo "blue toothsuccess"
else
    echo "blue toothfailed"
    exit -1
fi


echo "[1]if install kde  ?-------[default]"
echo "[2]if install gnome ? "
echo "[3]if install deepin lightdm?"
read -n1 -p "which would you want to install ?[1/2/3]" REPLY
if [[ $REPLY =~ ^[1]$ ]]; then
   pacman -S sddm plasma  --noconfirm
    systemctl enable sddm
    if [ $? -eq 0 ]; then
        echo "kde success"
    else
        echo "kde failed"
        exit -1
    fi

    read -n1 -p "would you want to install kde-applications?[y/n]" REPLY2
    if [[ $REPLY2 =~ ^[Yy]$ ]]; then
        pacman -S kde-applications  --noconfirm
        if [ $? -eq 0 ]; then
            echo "kde-applicationssuccess"
        else
            echo "kde-applicationsfailed"
            exit -1
        fi

    fi

    read -n1 -p "would you want to install kcm-fcitx?[y/n]" REPLY2
    if [[ $REPLY2 =~ ^[Yy]$ ]]; then
         pacman -S kcm-fcitx  --noconfirm
        if [ $? -eq 0 ]; then
            echo "kcm-fcitxsuccess"
        else
            echo "kcm-fcitxfailed"
            exit -1
        fi

    fi

elif [[ $REPLY =~ ^[2]$ ]]; then
     pacman -S gnome --noconfirm
    systemctl enable gdm
    if [ $? -eq 0 ]; then
        echo "gnome success"
    else
        echo "gnome failed"
        exit -1
    fi

elif [[ $REPLY =~ ^[3]$ ]]; then
 pacman -S deepin lightdm --noconfirm
    systemctl enable lightdm
    if [ $? -eq 0 ]; then
        echo "lightdm success"
    else
        echo "lightdm failed"
        exit -1
    fi

fi


read -p "Normal user " username
useradd -m -G wheel $username
echo "$username passwd"
passwd $username
if [ $? -eq 0 ]; then
    echo "user $username add success "
else
    echo "user $username add failed "
    exit -1
fi




echo "pinyin installing"
pacman -S fcitx fcitx-im fcitx-libpinyin --noconfirm
echo -e "GTK_IM_MODULE DEFAULT=fcitx\nQT_IM_MODULE  DEFAULT=fcitx\nXMODIFIERS    DEFAULT=@im=fcitx " >/home/$username/.pam_environment
chown  $username:$username /home/$username/.pam_environment
if [ $? -eq 0 ]; then
    echo "pinyinsuccess"
else
    echo "pinyinfailed"
    exit -1
fi



echo "$usernameuser language configing"
mkdir /home/$username/.config
chown  $username:$username /home/$username/.config
echo -e "LANG=zh_CN.UTF-8\nLC_CTYPE=\"zh_CN.UTF-8\"\nLC_NUMERIC=\"zh_CN.UTF-8\"\nLC_TIME=\"zh_CN.UTF-8\"\n
LC_COLLATE=\"zh_CN.UTF-8\"\nLC_MONETARY=\"zh_CN.UTF-8\"\nLC_MESSAGES=\"zh_CN.UTF-8\"\nLC_PAPER=\"zh_CN.UTF-8\"\n
LC_NAME=\"zh_CN.UTF-8\"\nLC_ADDRESS=\"zh_CN.UTF-8\"\nLC_TELEPHONE=\"zh_CN.UTF-8\"\nLC_MEASUREMENT=\"zh_CN.UTF-8\"\n
LC_IDENTIFICATION=\"zh_CN.UTF-8\"\nLC_ALL= " >/home/$username/.config/locale.conf
chown  $username:$username /home/$username/.config/locale.conf
if [ $? -eq 0 ]; then
    echo "$username user languageconfig success"
else
    echo "$username user languageconfig failed"
    exit -1
fi

echo "zsh configing"
pacman -S zsh oh-my-zsh-git zsh-syntax-highlighting zsh-autosuggestions autojump  --noconfirm
chsh -s /bin/zsh $username
ln -s /usr/share/zsh/plugins/zsh-syntax-highlighting /usr/share/oh-my-zsh/custom/plugins/
ln -s /usr/share/zsh/plugins/zsh-autosuggestions /usr/share/oh-my-zsh/custom/plugins/
cp /usr/share/oh-my-zsh/zshrc /home/$username/.zshrc
sed 's/plugins=(git)/plugins=(autojump git zsh-syntax-highlighting zsh-autosuggestions)/g' /home/$username/.zshrc
chown  $username:$username /home/$username/.zshrc
if [ $? -eq 0 ]; then
    echo "zshconfig success"
else
    echo "zshconfig failed"
    exit -1
fi


echo "reboot enter arch quickly"
exit 0
