#!/usr/bin/env -S bash -e

# Cleaning the TTY.
clear

# Pretty print (function).
print () {
    echo -e "\e[1m\e[93m[ \e[92m•\e[93m ] \e[4m$1\e[0m"
}

# Selecting a kernel to install (function). 
kernel_selector () {
    print "Installing Linux Zen kernel: A Linux kernel optimized for desktop usage"
    kernel="linux-zen"
}

# Selecting a way to handle internet connection (function). 
network_selector () {
    print "Installing NetworkManager."
    pacstrap /mnt networkmanager
    print "Enabling NetworkManager."
    systemctl enable NetworkManager --root=/mnt &>/dev/null
}


# Setting up the hostname (function).
hostname_selector () {
    hostname=no
    echo "$hostname" > /mnt/etc/hostname
}

# Setting up the locale (function).
locale_selector () {
    echo "$en_US.UTF-8 UTF-8"  > /mnt/etc/locale.gen
    echo "LANG=$en_US.UTF-8" > /mnt/etc/locale.conf
}


# Selecting the target for the installation.
print "Loading Ameya's Arch Linux for VM's basic setup"
DISK=/dev/sda
print "Installing Arch Linux on $DISK."

# Creating a new partition scheme.
print "Creating the partitions on $DISK."
parted -s "$DISK" \
    mklabel msdos \
    mkpart primary ext4 1MiB 100% \
    set 1 boot on

BOOT="dev/sda1"
# Formatting the ESP as FAT32.
print "Formatting the $BOOT partition as ext4."
mkfs.ext4 -F $BOOT &>/dev/null

# Mounting the newly created subvolumes.
print "Mounting the newly created volume."
mount $BOOT /mnt

# Setting up the kernel.
kernel_selector

# Pacstrap (setting up a base sytem onto the new root).
print "Installing the base system (it may take a while)."
pacstrap /mnt base $kernel base-devel nano

# Setting up the network.
network_selector

# Setting up the hostname.
hostname_selector

# Generating /etc/fstab.
print "Generating a new fstab."
genfstab -U /mnt >> /mnt/etc/fstab

# Setting up the locale.
locale_selector

# Setting hosts file.
print "Setting hosts file."
cat > /mnt/etc/hosts <<EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   $hostname.localdomain   $hostname
EOF


# Configuring the system.    
arch-chroot /mnt /bin/bash -e <<EOF

    # Setting up timezone.
    echo "Setting up the timezone."
    timedatectl set-timezone Asia/Kolkata
    
    # Generating locales.
    echo "Generating locales."
    locale-gen &>/dev/null
    
    # Installing GRUB.
    echo "Installing GRUB on /boot."
    pacman -S grub --needed &>/dev/null
    grub-install /dev/sda &>/dev/null

    # Creating grub config file.
    echo "Creating GRUB config file."
    grub-mkconfig -o /boot/grub/grub.cfg &>/dev/null

EOF

# Setting root password.
print "Setting root password."
arch-chroot /mnt /bin/passwd

# Finishing up.
print "Done, you may now wish to reboot (further changes can be done by chrooting into /mnt)."
exit
