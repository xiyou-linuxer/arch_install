ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
hwclock --systohc --utc
echo "时区更改完成"

echo -e "en_US.UTF-8 UTF-8 \nzh_CN.UTF-8 UTF-8 \nzh_TW.UTF-8 UTF-8" >>/etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >/etc/locale.conf
echo "(中国大陆)语系更改完成"

echo -e " [archlinuxcn] \n Include = /etc/pacman.d/archlinuxcn-mirrorlist " >>/etc/pacman.conf
echo -e "Server = https://mirrors.ustc.edu.cn/archlinuxcn/\$arch \nServer = https://mirrors.hit.edu.cn/archlinuxcn/\$arch" >/etc/pacman.d/archlinuxcn-mirrorlist
echo -e "\n" | pacman -Syy archlinuxcn-keyring
echo -e "\n" | pacman -S archlinuxcn-mirrorlist-git
echo "换源成功"

echo -e "\n" | pacman -S grub efibootmgr dosfstools
echo "引导程序安装完毕"

read -n1 -p "是否安装多系统引导?[y/n]" REPLY
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "\n" | pacman -S os-prober ntfs-3g
    echo "os-prober 安装完成"
fi

echo "生成grub 引导安装"
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub --recheck
grub-mkconfig -o /boot/grub/grub.cfg
echo "grub 引导安装完成"

read -p "输入主机名:" userhostname
echo $userhostname >>/etc/hostname
echo "主机名更改完成"

echo "输入root密码"
passwd

echo "%wheel ALL=(ALL) ALL " >>/etc/sudoers

read -p "输入个人用户名" username
useradd -m -G wheel $username
echo "输入$username 账户密码"
passwd $username
echo "用户$username添加完成"

echo "字体正在安装  (Google Noto Fonts 字体,思源黑体, 思源宋体,更纱黑体)"
echo -e "\n" | pacman -S noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra ttf-sarasa-gothic adobe-source-han-sans-cn-fonts adobe-source-han-serif-cn-fonts
echo "字体安装完成"

echo "网络管理器正在安装"
echo -e "\n" | pacman -S networkmanager
systemctl enable NetworkManager
echo "网络管理器安装完成"

echo "输入法正在安装"
echo -e "\n" | pacman -S fcitx fcitx-im fcitx-libpinyin
echo -e "GTK_IM_MODULE DEFAULT=fcitx\nQT_IM_MODULE  DEFAULT=fcitx\nXMODIFIERS    DEFAULT=@im=fcitx " >/home/$username/.pam_environment
echo "输入法安装完成"

echo "蓝牙正在安装"
echo -e "\n" | pacman -S bluez bluez-utils pulseaudio-bluetooth
modprobe btusb
systemctl enable bluetooth.service
echo "蓝牙安装完成"

echo "$username用户语系设置中"
echo -e "LANG=zh_CN.UTF-8\nLC_CTYPE=\"zh_CN.UTF-8\"\nLC_NUMERIC=\"zh_CN.UTF-8\"\nLC_TIME=\"zh_CN.UTF-8\"\n
LC_COLLATE=\"zh_CN.UTF-8\"\nLC_MONETARY=\"zh_CN.UTF-8\"\nLC_MESSAGES=\"zh_CN.UTF-8\"\nLC_PAPER=\"zh_CN.UTF-8\"\n
LC_NAME=\"zh_CN.UTF-8\"\nLC_ADDRESS=\"zh_CN.UTF-8\"\nLC_TELEPHONE=\"zh_CN.UTF-8\"\nLC_MEASUREMENT=\"zh_CN.UTF-8\"\n
LC_IDENTIFICATION=\"zh_CN.UTF-8\"\nLC_ALL= " >/home/$username/.config/locale.conf
echo "$username 用户语系设置完成"

echo "zsh正在配置"
echo -e "\n" | pacman -S zsh oh-my-zsh-git zsh-syntax-highlighting zsh-autosuggestions autojump
chsh -s /bin/zsh $username
ln -s /usr/share/zsh/plugins/zsh-syntax-highlighting /usr/share/oh-my-zsh/custom/plugins/
ln -s /usr/share/zsh/plugins/zsh-autosuggestions /usr/share/oh-my-zsh/custom/plugins/
cp /usr/share/oh-my-zsh/zshrc /home/$username/.zshrc
sed 's/plugins=(git)/plugins=(autojump git zsh-syntax-highlighting zsh-autosuggestions)' /home/$username/.zshrc
echo "zsh配置完成"

echo "[1]if install kde  ?-------[default]"
echo "[2]if install gnome ? "
echo "[3]if install deepin lightdm?"
read -n1 -p "which would you want to install ?[1/2/3]" REPLY
if [[ $REPLY =~ ^[1]$ ]]; then
    echo -e "\n" | pacman -S sddm plasma
    systemctl enable sddm
    echo "kde 安装完成"
    read -n1 -p "would you want to install kde-applications?[y/n]" REPLY2
    if [[ $REPLY2 =~ ^[Yy]$ ]]; then
        echo -e "\n" | pacman -S kde-applications
        echo "kde-applications安装完成"
    fi

    read -n1 -p "would you want to install kcm-fcitx?[y/n]" REPLY2
    if [[ $REPLY2 =~ ^[Yy]$ ]]; then
        echo -e "\n" | pacman -S kcm-fcitx
        echo "kcm-fcitx安装完成"
    fi

elif [[ $REPLY =~ ^[2]$ ]]; then
    echo -e "\n" | pacman -S gnome
    systemctl enable gdm
    echo "gnome 安装完成"
elif [[ $REPLY =~ ^[3]$ ]]; then
    echo -e "\n" | pacman -S deepin lightdm
    systemctl enable lightdm
    echo "lightdm 安装完成"
fi

echo "请尽快重启进入arch"
exit 0
