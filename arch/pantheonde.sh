#!/bin/bash 

# Pretty print (function).
print () {
    echo -e "\e[1m\e[93m[ \e[92m•\e[93m ] \e[4m$1\e[0m"
}

# Wait for enter to be pressed (debug function)
wait () {
    echo "Press [ENTER] to continue"
    while [ true ] ; do
        read -s -N 1 key
        if [[ $key == $'\x0a' ]];
        then
            return 0
        fi
    done
}
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

print "Welcome to the Pantheon Desktop Environment setup for Arch by Ameya"
DE_PROGS="pantheon-session gala wingpanel wingpanel-indicator-datetime wingpanel-indicator-network wingpanel-indicator-notifications wingpanel-indicator-power wingpanel-indicator-session pantheon-applications-menu plank"
SV_PROGS="pantheon-polkit-agent"
TC_PROGS="xorg-server lightdm lightdm-pantheon-greeter pantheon-default-settings elementary-icon-theme elementary-wallpapers gtk-theme-elementary ttf-droid ttf-opensans ttf-roboto sound-theme-elementary switchboard switchboard-plug-about switchboard-plug-applications switchboard-plug-datetime switchboard-plug-desktop switchboard-plug-display switchboard-plug-keyboard switchboard-plug-locale switchboard-plug-network switchboard-plug-notifications switchboard-plug-power switchboard-plug-printers switchboard-plug-user-accounts"
AP_PROGS="pantheon-files pantheon-terminal man-db man-pages texinfo"

pacman -S $DE_PROGS $SV_PROGS $TC_PROGS $AP_PROGS --needed --noconfirm

print "Setting up LightDM"
sed -i 's/#greeter-session=example-gtk-gnome/greeter-session=io.elementary.greeter/' /etc/lightdm/lightdm.conf

print "Enabling LightDM"
systemctl enable lightdm

print "Adding plank to startup"
cat > /etc/xdg/autostart/plank.desktop <<EOF
[Desktop Entry]
Name=Plank
Comment=Stupidly simple.
Exec=plank
Icon=plank
Terminal=false
Type=Application
Categories=Utility;
NoDisplay=true
X-GNOME-Autostart-Notify=false
X-GNOME-AutoRestart=true
X-GNOME-Autostart-enabled=true
X-GNOME-Autostart-Phase=Panel
OnlyShowIn=Pantheon;

EOF

print "Setting up yay from AUR"
USER=no
print "WARNING: this will be run as the user $USER."
wait

pacman -S git --needed --noconfirm
sudo -u $USER bash <<EOF
cd /tmp
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -sic --noconfirm --needed
rm -rf /tmp/yay

EOF

print "Finished setup! Reboot to enjoy the Pantheon Experience"

