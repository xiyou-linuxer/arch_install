#!/bin/bash
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
hwclock --systohc --utc
if [ $? -eq 0 ]; then
    echo "时区更改完成"
else
    echo "时区更改失败"
    exit -1
fi

echo -e "en_US.UTF-8 UTF-8 \nzh_CN.UTF-8 UTF-8 \nzh_TW.UTF-8 UTF-8" >>/etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >/etc/locale.conf
if [ $? -eq 0 ]; then
    echo "(中国大陆)语系更改完成"
else
    echo "(中国大陆)语系更改失败"
    exit -1
fi

echo -e " [archlinuxcn] \n Include = /etc/pacman.d/archlinuxcn-mirrorlist " >>/etc/pacman.conf
echo -e "Server = https://mirrors.ustc.edu.cn/archlinuxcn/\$arch \nServer = https://mirrors.hit.edu.cn/archlinuxcn/\$arch" >/etc/pacman.d/archlinuxcn-mirrorlist
echo -e "\n" | pacman -Syy archlinuxcn-keyring
echo -e "\n" | pacman -S archlinuxcn-mirrorlist-git
if [ $? -eq 0 ]; then
    echo "换源完成"
else
    echo "换源失败"
    exit -1
fi

echo -e "\n" | pacman -S grub efibootmgr dosfstools
if [ $? -eq 0 ]; then
    echo "引导程序安装完成"
else
    echo "引导程序安装失败"
    exit -1
fi

read -n1 -p "是否安装多系统引导?[y/n]" REPLY
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "\n" | pacman -S os-prober ntfs-3g
    if [ $? -eq 0 ]; then
        echo "os-prober 安装完成"
    else
        echo "os-prober 安装失败"
        exit -1
    fi

fi

echo "生成grub 引导安装"
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub --recheck
grub-mkconfig -o /boot/grub/grub.cfg
if [ $? -eq 0 ]; then
    echo "grub 引导安装完成"
else
    echo "grub 引导安装失败"
    exit -1
fi

read -p "输入主机名:" userhostname
echo $userhostname >>/etc/hostname
if [ $? -eq 0 ]; then
    echo "主机名更改完成"
else
    echo "主机名更改失败"
    exit -1
fi

echo "输入root密码"
passwd

echo "%wheel ALL=(ALL) ALL " >>/etc/sudoers

read -p "输入个人用户名" username
useradd -m -G wheel $username
echo "输入$username 账户密码"
passwd $username
if [ $? -eq 0 ]; then
    echo "用户$username添加完成"
else
    echo "用户$username添加失败"
    exit -1
fi

echo "字体正在安装  (Google Noto Fonts 字体,思源黑体, 思源宋体,更纱黑体)"
echo -e "\n" | pacman -S noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra ttf-sarasa-gothic adobe-source-han-sans-cn-fonts adobe-source-han-serif-cn-fonts
if [ $? -eq 0 ]; then
    echo "字体安装完成"
else
    echo "字体安装失败"
    exit -1
fi

echo "网络管理器正在安装"
echo -e "\n" | pacman -S networkmanager
systemctl enable NetworkManager
if [ $? -eq 0 ]; then
    echo "网络管理器安装完成"
else
    echo "网络管理器安装失败"
    exit -1
fi

echo "输入法正在安装"
echo -e "\n" | pacman -S fcitx fcitx-im fcitx-libpinyin
echo -e "GTK_IM_MODULE DEFAULT=fcitx\nQT_IM_MODULE  DEFAULT=fcitx\nXMODIFIERS    DEFAULT=@im=fcitx " >/home/$username/.pam_environment
if [ $? -eq 0 ]; then
    echo "输入法安装完成"
else
    echo "输入法安装失败"
    exit -1
fi

echo "蓝牙正在安装"
echo -e "\n" | pacman -S bluez bluez-utils pulseaudio-bluetooth
modprobe btusb
systemctl enable bluetooth.service
if [ $? -eq 0 ]; then
    echo "蓝牙安装完成"
else
    echo "蓝牙安装失败"
    exit -1
fi

echo "$username用户语系设置中"
echo -e "LANG=zh_CN.UTF-8\nLC_CTYPE=\"zh_CN.UTF-8\"\nLC_NUMERIC=\"zh_CN.UTF-8\"\nLC_TIME=\"zh_CN.UTF-8\"\n
LC_COLLATE=\"zh_CN.UTF-8\"\nLC_MONETARY=\"zh_CN.UTF-8\"\nLC_MESSAGES=\"zh_CN.UTF-8\"\nLC_PAPER=\"zh_CN.UTF-8\"\n
LC_NAME=\"zh_CN.UTF-8\"\nLC_ADDRESS=\"zh_CN.UTF-8\"\nLC_TELEPHONE=\"zh_CN.UTF-8\"\nLC_MEASUREMENT=\"zh_CN.UTF-8\"\n
LC_IDENTIFICATION=\"zh_CN.UTF-8\"\nLC_ALL= " >/home/$username/.config/locale.conf
if [ $? -eq 0 ]; then
    echo "$username 用户语系设置完成"
else
    echo "$username 用户语系设置失败"
    exit -1
fi

echo "zsh正在配置"
echo -e "\n" | pacman -S zsh oh-my-zsh-git zsh-syntax-highlighting zsh-autosuggestions autojump
chsh -s /bin/zsh $username
ln -s /usr/share/zsh/plugins/zsh-syntax-highlighting /usr/share/oh-my-zsh/custom/plugins/
ln -s /usr/share/zsh/plugins/zsh-autosuggestions /usr/share/oh-my-zsh/custom/plugins/
cp /usr/share/oh-my-zsh/zshrc /home/$username/.zshrc
sed 's/plugins=(git)/plugins=(autojump git zsh-syntax-highlighting zsh-autosuggestions)' /home/$username/.zshrc
if [ $? -eq 0 ]; then
    echo "zsh配置完成"
else
    echo "zsh配置失败"
    exit -1
fi

echo "[1]if install kde  ?-------[default]"
echo "[2]if install gnome ? "
echo "[3]if install deepin lightdm?"
read -n1 -p "which would you want to install ?[1/2/3]" REPLY
if [[ $REPLY =~ ^[1]$ ]]; then
    echo -e "\n" | pacman -S sddm plasma
    systemctl enable sddm
    if [ $? -eq 0 ]; then
        echo "kde 安装完成"
    else
        echo "kde 安装失败"
        exit -1
    fi

    read -n1 -p "would you want to install kde-applications?[y/n]" REPLY2
    if [[ $REPLY2 =~ ^[Yy]$ ]]; then
        echo -e "\n" | pacman -S kde-applications
        if [ $? -eq 0 ]; then
            echo "kde-applications安装完成"
        else
            echo "kde-applications安装失败"
            exit -1
        fi

    fi

    read -n1 -p "would you want to install kcm-fcitx?[y/n]" REPLY2
    if [[ $REPLY2 =~ ^[Yy]$ ]]; then
        echo -e "\n" | pacman -S kcm-fcitx
        if [ $? -eq 0 ]; then
            echo "kcm-fcitx安装完成"
        else
            echo "kcm-fcitx安装失败"
            exit -1
        fi

    fi

elif [[ $REPLY =~ ^[2]$ ]]; then
    echo -e "\n" | pacman -S gnome
    systemctl enable gdm
    if [ $? -eq 0 ]; then
        echo "gnome 安装完成"
    else
        echo "gnome 安装失败"
        exit -1
    fi

elif [[ $REPLY =~ ^[3]$ ]]; then
    echo -e "\n" | pacman -S deepin lightdm
    systemctl enable lightdm
    if [ $? -eq 0 ]; then
        echo "lightdm 安装完成"
    else
        echo "lightdm 安装失败"
        exit -1
    fi

fi

echo "请尽快重启进入arch"
exit 0
