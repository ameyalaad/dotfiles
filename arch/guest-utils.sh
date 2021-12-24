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

# Virtualization check (function).
virt_check () {
    hypervisor=$(systemd-detect-virt)
    case $hypervisor in
        kvm )   print "KVM has been detected."
                print "Installing guest tools."
                pacman -S qemu-guest-agent --needed --noconfirm
                print "Enabling specific services for the guest tools."
                systemctl enable qemu-guest-agent
                ;;
        vmware  )   print "VMWare Workstation/ESXi has been detected."
                    print "Installing guest tools."
                    pacman -S open-vm-tools --needed --noconfirm
                    print "Enabling specific services for the guest tools."
                    systemctl enable vmtoolsd
                    systemctl enable vmware-vmblock-fuse
                    ;;
        oracle )    print "VirtualBox has been detected."
                    print "Installing guest tools."
                    pacman -S virtualbox-guest-utils --needed --noconfirm
                    print "Enabling specific services for the guest tools."
                    systemctl enable vboxservice
                    ;;
        microsoft ) print "Hyper-V has been detected."
                    print "Installing guest tools."
                    pacman -S hyperv --needed --noconfirm
                    print "Enabling specific services for the guest tools."
                    systemctl enable hv_fcopy_daemon
                    systemctl enable hv_kvp_daemon
                    systemctl enable hv_vss_daemon 
                    ;;
        * ) ;;
    esac
}
virt_check
