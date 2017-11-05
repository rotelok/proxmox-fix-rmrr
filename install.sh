#!/bin/bash
# PVE Kernel Patcher
CURRENT_DIR=$(pwd)
SOURCES_DIR=/usr/src/

mkdir deb
apt-get install git nano screen patch \
                fakeroot build-essential devscripts libncurses5 \
                libncurses5-dev libssl-dev bc flex \
                bison libelf-dev libaudit-dev libgtk2.0-dev \
                libperl-dev libperl-dev asciidoc xmlto \
                gnupg gnupg2 gdebi -y

cd $SOURCES_DIR
git clone git://git.proxmox.com/git/pve-kernel.git
cd pve-kernel

# Find the Version
PVE_VERSION=$(cat Makefile | grep "RELEASE="| cut -d "=" -f2)
KERNEL_VERSION=$(cat Makefile | grep KERNEL_SRC=| cut -d "=" -f2)

if [[ $PVE_VERSION == 4.4 ]];then
    echo "TODO:PVE 4.4"
elif [[ $PVE_VERSION == 5.0 ]];then
    # In pve5.0 we need to copy our patch and make a patch to the Makefile
    echo "TODO:PVE 5.0"
elif [[ $PVE_VERSION == 5.1 ]];then
    # If pve 5.1 we don't need to patch the makefile, just copy our .patch file
    cp CURRENT_DIR/patches/007-rmrr-patch-proxmox.5.1.patch patches/kernel/
fi

#Build the kernel
make


# Post Build Stuff
mv *.deb $CURRENT_DIR/deb/


# Post compile clean up
cd $SOURCES_DIR
rm -rf pve-kernel


# Install stuff


# Post Install Stuff
echo "# Enable unsafe interrupts
# Disable msrs to fix some problems with NVIDIA cards in windows
options vfio_iommu_type1 allow_unsafe_interrupts=1
options kvm ignore_msrs=Y

# Here you choose which devices you want to passthrough, ie:
# lspci -nn | grep -i NVIDIA
#   07:00.0 VGA compatible controller [0300]: NVIDIA Corporation GK107 [NVS 510] [10de:0ffd] (rev a1)
#   07:00.1 Audio device [0403]: NVIDIA Corporation GK107 HDMI Audio Controller [10de:0e1b] (rev a1)
# in this case you would use 10de:0ffd (video card ) and 10de:0e1b ( hdmi audio )
# should work with most cards

options vfio-pci ids=10de:0ffd,10de:0e1b

" > /etc/modprobe.d/kvm-vfio.conf


# Loading the vfio modules during boot
echo "
#vfio modules
pci_stub
vfio
vfio_iommu_type1
vfio_pci
vfio_virqfd
" >> /etc/modules

